function submit(id, spec)
%SUBMIT  Start ONE design on the pool. Returns immediately.
    FUT = evalin('base', 'FUT');
    FUT(id) = parfeval(@evaluate_design, 1, spec);
end
