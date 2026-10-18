function setup_cluster(profile, n)
%SETUP_CLUSTER  Open the pool once and create the store for running jobs.
%   profile : your Parallel Server profile name (use 'local' to test on your machine)
%   n       : number of workers
    if isempty(gcp('nocreate'))
        parpool('local', n);
    end
    % FUT holds the currently-running designs, keyed by id. It is a handle,
    % so submit() and poll() both see the same object.
    assignin('base', 'FUT', containers.Map('KeyType', 'double', 'ValueType', 'any'));
end
