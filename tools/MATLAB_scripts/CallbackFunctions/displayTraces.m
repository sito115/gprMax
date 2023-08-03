function displayTraces(src, event, data, component,mode)
% Call the function  plot_TimeFreqDomain.m for either data with gain or
% original data 'raw'.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs
% data          : structure with one single entry containing data of laoded. out file
% component     : character [Ex,Ey,Ez]
% mode          : chracter either 'raw' or 'displayed'
    switch mode 
        case 'raw'
            plot_TimeFreqDomain(data, component)
        case 'displayed'
            h = findobj(gca().Children,'Type','Image');
            fields = fieldnames(data);
            data.(fields{1}).Data.fields.(component) = h.CData;
            plot_TimeFreqDomain(data, component)
    end
end