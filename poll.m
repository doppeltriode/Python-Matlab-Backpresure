function [done, val] = poll(id)
%POLL  Ask about ONE design. Non-blocking.
%   done = true and val = result once it has finished (NaN if it errored).
%   done = false while it is still running.
    FUT = evalin('base', 'FUT');
    f = FUT(id);
    if strcmp(f.State, 'finished')
        done = true;
        try
            val = fetchOutputs(f);
        catch
            val = NaN;            % this design failed -> record NaN, keep going
        end
        remove(FUT, id);          % drop it so the store stays small
    else
        done = false;
        val = NaN;
    end
end
