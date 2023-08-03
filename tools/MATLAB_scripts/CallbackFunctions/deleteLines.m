function deleteLines(src,event)
% Delete velocity estimations lines that can be selected in a GUI.
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs



h     = findobj(gca,'Tag','velocityEst');
lines = findobj(h, 'Type','Line');
txt = findobj(h, 'Type','Text');
displayNames = strings(numel(h),1);
for i = 1:numel(lines)
    try
        displayNames(i) = lines(i).DisplayName;
    catch
        continue
    end
end

for i = 1:numel(txt)
    try
        displayNames(numel(lines)+i) = txt(i).String;
    catch
        continue
    end
end

displayNames = unique(displayNames);

[sel_indx,tf] = listdlg('PromptString','Delete velocity estimations',...
    'SelectionMode','single','ListString',displayNames, 'ListSize', [500, 200]);

if tf
    for i = sel_indx
        name = displayNames(i);
        for k = 1:numel(h)
            if strcmpi(get(h(k),'Type'),'Line')
                if contains(h(k).DisplayName,name)
                    delete(h(k))
                end
            elseif strcmpi(get(h(k),'Type'),'Text')
                if contains(h(k).String,name) 
                    delete(h(k))
                end
            end
        end
    end
end

end
