function data = gpr_gainInvEnv2D(indata)
% function data = gpr_gainInvEnv2D(indata, tracewindow,nr_of_traces, dt)
data        = indata; %zeros(size(indata));
nr_of_traces = size(indata,2);
for ii = 1:nr_of_traces
    hd         = hilbert(indata(:,ii));
    env        = sum(sqrt(hd.*conj(hd)), 2);
    data(:,ii) = indata(:,ii)./env;
end
% timewindow  = [round(0.33*nSamples) round(0.66*nSamples)];
% tracewindow = nSamples;
% cas = 3;

% sampling_rate = 1/(nSamples*dt);
% 
% switch cas
%     case 1
%         for ii = 1:nr_of_traces
%             
%             tracerange = max(1,ii-tracewindow/2)+1:min(size(indata,2), ii+tracewindow/2);
%             hd         = hilbert(indata(:,tracerange));
%             env        = sum(sqrt(hd.*conj(hd)), 2)./length(tracerange);
%             
%             cc = polyfit(timewindow, log(env(timewindow))', 1);
%             
%             samplerange = 1:timewindow(1);
%             data(samplerange, ii) = indata(samplerange, ii)./exp(polyval(cc, samplerange(end)*sampling_rate)).';
%             
%             samplerange = timewindow(1):timewindow(2);
%             data(samplerange, ii) = indata(samplerange, ii)./exp(polyval(cc, samplerange*sampling_rate)).';
%             
%             samplerange = timewindow(2)+1:size(indata,1);
%             data(samplerange, ii) = indata(samplerange, ii)./exp(polyval(cc, samplerange(1)*sampling_rate)).';
%             disp(ii)
%         end
%         
%     case 2
%         tracerange = 1:nr_of_traces;
%         hd         = hilbert(indata(:,tracerange));
%         env        = sum(sqrt(hd.*conj(hd)), 2)./length(tracerange);
%         
%         cc = polyfit(timewindow(1):timewindow(2), log(env(timewindow(1):timewindow(2)))', 1);
%         
%         for ii = 1:nr_of_traces
%         samplerange = 1:timewindow(1);
%         data(samplerange, ii) = indata(samplerange, ii)*0.2./exp(polyval(cc, samplerange(end)*sampling_rate)).';
%         
%         samplerange = timewindow(1)+1:timewindow(2);
%         data(samplerange, ii) = indata(samplerange, ii)./exp(polyval(cc, samplerange*sampling_rate)).';
%         
%         samplerange = timewindow(2)+1:size(indata,1);
%         data(samplerange, ii) = indata(samplerange, ii)./exp(polyval(cc, samplerange(1)*sampling_rate)).';
%         end
        
%     case 3

% end
% trnumber = round(linspace(1,ntr,floor(ntr/trint)+1));
% figure
% hold on
% hd = hilbert(data);
% %env = zeros(ns,1);
% for ii = 2:length(trnumber)
%     env = sum(sqrt(hd(:,trnumber(ii-1)+1:trnumber(ii)).*...
%         conj(hd(:,trnumber(ii-1)+1:trnumber(ii)))),2)./(trnumber(ii)-trnumber(ii-1)+1);
%     % for a = 1:ntr
%     %     env = env + sqrt(hd(:,a).*conj(hd(:,a)));
%     % end;
%     % env = env/ntr;
%
%     cc = polyfit(t(s1:s2),log(env(s1:s2))',1);
%
%     for a = 1:s2
%         data(a,trnumber(ii-1)+1:trnumber(ii)) = data(a,trnumber(ii-1)+1:trnumber(ii))/exp(polyval(cc,t(a)));
%     end;
%
%     for a = s2+1:ns
%         data(a,trnumber(ii-1)+1:trnumber(ii)) = data(a,trnumber(ii-1)+1:trnumber(ii))/exp(polyval(cc,t(s2)));
%     end
%
%
%     plot(1:ns,log(env'),'b',s1:s2,polyval(cc,t(s1:s2)),'g',s1:s2,1./polyval(cc,t(s1:s2)),'r')
% end
% if nargin > 2
%     n = n +1;
% end

end