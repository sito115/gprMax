function addTitle(src, event, t, fs)
% Add a title to Matlab figure
% INPUT:
% scr,event     : parameters of callbacks in Matlab, see Docs
% t             : tiled layout object
% fs            : font size in pts
%


dlgtitle = 'AddTitle';

if isempty(t.Title.String)
    lgObj = findobj(gcf,'Type','Legend');
    prompt = lgObj.String(1);
else
    prompt = t.Title.String;
end

answer = inputdlg('New title',dlgtitle,[1 150],prompt);

title(t,answer, 'FontSize', 1.3*fs)

end