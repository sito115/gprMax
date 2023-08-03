function allData = load_output(allData, filenameArray,pathname, isFFT)
% Load data of an out.-File into a structure
% INPUT:
% allData       : structure containing information about loaded data
% filenameArray : cell array -
% pathname      : character -
% isFFT         : logical - include FFT when loading the put
%
% OUTPUT: 
% allData       : structure containing information about loaded data

if nargin < 4 || isempty(isFFT)
    isFFT = true;
end

if iscell(filenameArray)
    for iFile = 1:numel(filenameArray)
        fileName = filenameArray{iFile};
        allData = loadData(allData, pathname, fileName, isFFT);
    end
else
     allData = loadData(allData, pathname, filenameArray, isFFT);
end

end

%% LOCAL
% loadData
function allData = loadData(allData, pathname, fileName, isFFT)
    [newData, fieldName] = fft_gprMaxOutput(pathname, fileName, isFFT);
    fieldNameStruc = local_checkDuplicate(allData, fieldName);
    allData.(fieldNameStruc) = newData.(fieldName);
end

% local_checkDuplicate
function fieldName = local_checkDuplicate(allData, fieldName)

if ~isempty(allData)
    fieldNames = fieldnames(allData);
    
    if ismember(fieldName, fieldNames)
        nAppearence = count(fieldName, fieldNames);
        fieldName = append(fieldName, num2str(nAppearence+1));
    
    end
end  
end
