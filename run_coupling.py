"""
Python refinement loops that call MATLAB models, running in parallel on a cluster.

- Each refinement loop lives in Python and calls evaluate(spec) whenever it needs
  a MATLAB model run for one design.
- evaluate(spec) sends that one design to MATLAB (one parfeval) and waits for its
  own result. Nothing is batched.
- The loops run in parallel in a thread pool. The pool size CAP is the number of
  designs allowed to evaluate at once -> that is the back pressure.
"""

import csv
import itertools
import threading
import time
from concurrent.futures import ThreadPoolExecutor

import matlab.engine

# ---- the one knob ----
CAP  = 2        # designs evaluating at once (also the number of loops in parallel)
POLL = 0.01      # seconds between "is it done?" checks; set to about 1/10 of a design's time

# ---- start MATLAB and open the pool ----
eng = matlab.engine.start_matlab()
eng.addpath(eng.pwd(), nargout=0)                 # folder holding the .m files
eng.setup_cluster("local", CAP, nargout=0)        # replace "local" with your cluster profile

# ---- shared bits (small, and they have to be here) ----
_ids         = itertools.count(1)     # unique id per design
_engine_lock = threading.Lock()       # one engine, so one call at a time
_csv_lock    = threading.Lock()       # one file, so one writer at a time

_csv = open("results.csv", "w", newline="")
_writer = csv.writer(_csv)
_writer.writerow(["id", "result"])
_csv.flush()


def evaluate(spec):
    """Run ONE design's MATLAB model and return its result. Call this from your loop."""
    design_id = next(_ids)

    with _engine_lock:
        eng.submit(float(design_id), spec, nargout=0)

    while True:
        with _engine_lock:
            done, val = eng.poll(float(design_id), nargout=2)
        if done:
            break
        time.sleep(POLL)

    val = float(val)
    with _csv_lock:
        _writer.writerow([design_id, val])
        _csv.flush()                  # live: the row is on disk now
    return val


def refine(design):
    """YOUR refinement loop for one design. This is just an example of the shape:
    call evaluate() whenever you need the MATLAB model, iterate as you like."""
    spec = design
    for _ in range(3):
        result = evaluate(spec)       # <- crosses into MATLAB, runs on the cluster
        spec = improve(spec, result)  # <- your Python-side model
    return spec


def improve(spec, result):
    # placeholder for your Python model
    spec = result + spec
    return spec


def main():
    designs = list(range(1000))       # <- you provide the real designs

    with ThreadPoolExecutor(max_workers=CAP) as pool:
        results = list(pool.map(refine, designs))

    _csv.close()
    eng.quit()
    print(f"Done. {len(results)} designs refined, results in results.csv")


if __name__ == "__main__":
    main()
