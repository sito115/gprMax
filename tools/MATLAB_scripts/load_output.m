function allData = load_output(allData, filenameArray,pathname)
% filenameArray = cell array
% pathname      = string
% allData       = structure

% allData       = structure

if iscell(filenameArray)
    for iFile = 1:numel(filenameArray)
        fileName = filenameArray{iFile};
        allData = loadData(allData, pathname, fileName);
    end
else
     allData = loadData(allData, pathname, filenameArray);
end

end

%% LOCAL
% loadData
function allData = loadData(allData, pathname, fileName)
    [newData, fieldName] = fft_gprMaxOutput(pathname, fileName);
    fieldName = local_checkDuplicate(allData, fieldName);
    allData.(fieldName) = newData.(fieldName);
end

% local_checkDuplicate
function fieldName = local_checkDuplicate(allData, fieldName)

fieldNames = fieldnames(allData);

if ismember(fieldName, fieldNames)
    nAppearence = count(fieldName, fieldNames);
    fieldName = append(fieldName, num2str(nAppearence+1));
end
     
end
