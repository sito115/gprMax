function [data,env] = gpr_gainInvEnv2D(indata)
% Gain function to divide a trace by its envelope (Hilbert gain)
%
% INPUT:
% indata : double [mxn] of B-scan
%
% OUTPUT:
% data   : double [mxn] - indata with gain
% env    : double [mxn] - envelope function of each trace.

data        = indata; %zeros(size(indata));
nr_of_traces = size(indata,2);
env = zeros(size(data));
for ii = 1:nr_of_traces
    hd         = hilbert(indata(:,ii));
    env(:,ii)  = sum(sqrt(hd.*conj(hd)), 2);
    data(:,ii) = indata(:,ii)./env(:,ii);
end

end