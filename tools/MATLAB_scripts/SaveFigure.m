function SaveFigure(src, event, path)

    if nargin < 3 || isempty(path)
        path = pwd;
    end

    filterUI = {'*.pdf';'*.jpg';'*.fig';'*.*'};
    
    
    [file,Selpath] = uiputfile(filterUI,'defname', fullfile(path,'MyFigure')); 

    fprintf('Saving %s...', file)
    
    exportgraphics(gcf,fullfile(Selpath, file  ) ,...
                   'ContentType','vector',...
                   'BackgroundColor','none')  
    
    fprintf('Done\n')

end