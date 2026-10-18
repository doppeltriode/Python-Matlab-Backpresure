function [done, L_Loss, T_max] = poll(id)
%POLL  Ask about ONE design. Non-blocking.
%   done = true  -> finished; L_Loss and T_max hold the result (NaN if it errored)
%   done = false -> still running; L_Loss and T_max are NaN
    FUT = evalin('base', 'FUT');
    f = FUT(id);
    if strcmp(f.State, 'finished')
        done = true;
        try
            [L_Loss, T_max] = fetchOutputs(f);
        catch
            L_Loss = NaN;   % this design failed -> NaN, keep going
            T_max  = NaN;
        end
        remove(FUT, id);        % drop it so the store stays small
    else
        done = false;
        L_Loss = NaN;
        T_max  = NaN;
    end
end