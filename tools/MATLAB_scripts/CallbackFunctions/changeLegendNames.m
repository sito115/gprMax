function changeLegendNames(src, event)
% Change Legend names of a figure in a GUI:
% INPUT:
% src,event     : mandatory inputs for callback functions, see Matlab Docs

lgObj = findobj(gcf,'Type','Legend');
prompt = lgObj.String;

dlgtitle = 'Change Legend Entry';

answer = inputdlg(prompt',dlgtitle,[1 150],prompt');

set(lgObj,'String',answer)

end