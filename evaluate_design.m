function r = evaluate_design(spec)
%EVALUATE_DESIGN  Your MATLAB model for ONE design. Runs on a pool worker.
%   spec is whatever you passed from Python (number, array, struct, ...).
%   Replace the body with your real model.
    r = norm(spec);
end
