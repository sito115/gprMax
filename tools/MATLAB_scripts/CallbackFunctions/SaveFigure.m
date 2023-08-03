function SaveFigure(src, event, path,fileName,isVector,isCorrectFileName)
% Define a line where to pick the maximum amplitude in a B-scan (detailed description in chapter 5.1.2).
% The user can set two points in the B-scan where a velocity line is drawn
% and specify a time buffer zone. A time window along this zone is
% extracted where the amplitudes are picked either as global maximum or
% first amplitude.
%
% INPUT:
% src,event         : mandatory inputs for callback functions, see Matlab Docs
% path              : character - save path [optional]
% fileName          : character -  file name  [optional]
% isVector          : logical - save as vector graphic (pdf) or not (png)
% isCorrectFileName : logical - display message box when successfully saved


    if nargin < 3 || isempty(path)
        path = pwd;
    end

    if nargin < 4 || isempty(fileName)
        fileName = 'MyFigure';
    end

    if nargin < 5 || isempty(fileName)
        isVector = true;
    end

    if nargin < 6 || isempty(isCorrectFileName)
        isCorrectFileName = false;
    end

    filterUI = {'*.pdf';'*.jpg';'*.fig';'*.png';'*.*'};
    
    if isCorrectFileName
        Selpath = path;
        if isVector
            file = [fileName '.pdf'];
        else
            file = [fileName '.png'];
        end
    else
      [file,Selpath] = uiputfile(filterUI,'defname', fullfile(path,fileName)); 
    end

    fprintf('Saving %s...', file)
    
    if isVector
        exportgraphics(gcf,fullfile(Selpath, file  ) ,...
                   'ContentType','vector',...
                   'BackgroundColor','none')  
    else
        saveas(gcf,fullfile(Selpath,file))
    end
    
    fprintf('Done\n')

    if ~isCorrectFileName
        msgbox(sprintf('Successfully saved %s',file))
    end

end