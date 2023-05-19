function deleteLine(src, event, timePlot, freqPlot, mode1, mode2) 

if nargin < 6 || isempty(mode2)
    mode2 = 'select';
end

timeLines = findobj(timePlot, 'Type', 'line');
freqLines = findobj(freqPlot, 'Type', 'line');

showTF = zeros(numel(timeLines),1);
lines  = strings(numel(timeLines),1);
for iLine = 1:numel(timeLines)
    lines(iLine) = timeLines(iLine).DisplayName;
    if isempty(timeLines(iLine).UserData) || timeLines(iLine).UserData.ShowLine
        showTF(iLine) = 1;
    end
end

switch mode1
    case 'hide'
    assert(any(showTF), 'No Lines to hide') 
    switch mode2
        case 'select'
   
            [sel_indx,tf] = select(lines(showTF==1));
        
            indx = find(showTF);
            indx = indx(sel_indx);
        case 'filter'
            answer = filter();
            idx    = contains(lines,answer,'IgnoreCase',true);
            indx   = find(idx);
            tf     = true;


    end

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'off';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle = 'off';
            timeLines(ix).UserData.ShowLine = 0;
            freqLines(ix).Visible = 'off';
            freqLines(ix).Annotation.LegendInformation.IconDisplayStyle = 'off';
            freqLines(ix).UserData.ShowLine = 0;
        end
    else
        fprintf('No lines selected')
    end

    case 'show'

    assert(any(~showTF), 'No Lines to hide')

    switch mode2
        case 'select'
            [sel_indx,tf] = select(lines(showTF==0));
        
            indx = find(~showTF);
            indx = indx(sel_indx);
        case 'filter'
            answer = filter();
            idx    = contains(lines,answer,'IgnoreCase',true);
            indx   = find(idx);
            tf     = true;
    end

    if tf
        for ix = indx'
            timeLines(ix).Visible = 'on';
            timeLines(ix).Annotation.LegendInformation.IconDisplayStyle= 'on';
            timeLines(ix).UserData.ShowLine = 1;
            freqLines(ix).Visible = 'on';
            freqLines(ix).Annotation.LegendInformation.IconDisplayStyle= 'on';
            freqLines(ix).UserData.ShowLine = 1;
        end
    else
        fprintf('No lines selected')
    end

    case 'delete'
        [sel_indx,tf] = select(lines);

        if tf
            for i = sel_indx
                delete(timeLines(i))
                delete(freqLines(i))
            end
        end
end


end

%%
function [sel_indx,tf] = select(list)
            [sel_indx,tf] = listdlg('PromptString','Delete Lines',...
        'Selectionmode','multiple','ListString',list, 'ListSize', [500, 200]);

end
%%
function answer = filter()
    prompt = {'Filter all lines that do contain:'};
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'Trace'};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
end