function allData = load_output(allData, filenameArray,pathname, isFFT)
% filenameArray = cell array
% pathname      = string
% allData       = structure

% allData       = structure

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
