%% gain
% https://link.springer.com/referenceworkentry/10.1007/978-3-030-26050-7_47-1
function result = gain(traces,windowlength, dt)
n = ceil(windowlength / dt);
if mod(n,2) == 0
    n = n + 1;
end
m = (n-1)/2;

gain = ones(size(traces));

% 1. De-mean value
for iTrace = 1:size(traces,2)
    currentTrace = traces(:,iTrace);
    for iValue = m+1:size(traces,1)-m
        index_low  = iValue-m;
        index_up   = iValue+m;
        tracesInTw    = currentTrace(index_low:index_up);
        traces_mean   = mean(tracesInTw);
        crit1 = tracesInTw > traces_mean;
        crit2 = tracesInTw < traces_mean;
        if traces_mean > 0
            traces_demean = (tracesInTw -traces_mean).*crit1 + tracesInTw.*(~crit1);
        else
            traces_demean = (tracesInTw +traces_mean).*crit2 + tracesInTw.*(~crit2);
        end

        if mean(traces_demean) > 1e-1
            fprintf('Mean of "demeaned" center point %d of trace %d is %f\n',iValue, iTrace, mean(traces_demean))
        end

        energy = 1/numel(tracesInTw)*sum(traces_demean.^2);
        gain(iValue, iTrace) = 1/energy;
         
%         agc(iValue,iTrace) = currentTrace(iValue) / gain_energy;
    end
end

result = traces .* gain;

end


%% fgain2
function result = gain2(traces,nSegments)

result = zeros(size(traces));
nSamples     = size(traces,1);
nSubSamples = floor(nSamples/nSegments);
index       = 1:nSubSamples:nSamples;
index(end)  = nSamples;

rms_a_stuetz = zeros(nSegments,size(traces,2));
rms_a        = zeros(size(traces));
midpoints    = zeros(nSegments,1);
for iTrace = 1:size(traces,2)
    currentTrace = traces(:,iTrace);
    for iSample = 1:numel(index)-1
        currentSubTrace = currentTrace(index(iSample):index(iSample+1));
        midpoints(iSample) = floor(mean(index(iSample)+index(iSample+1)));
        local_mean      = mean(currentSubTrace);
        rms_a_stuetz(iSample, iTrace)           = sqrt(1/numel(currentSubTrace)*sum((currentSubTrace-local_mean).^2));
    end
    rms_a(:,iTrace) = spline(midpoints, rms_a_stuetz(:,iTrace),1:nSamples);
    const = mean(rms_a(:,iTrace));
    result(:,iTrace) = const./rms_a(:,iTrace).*traces(:,iTrace);
end

end