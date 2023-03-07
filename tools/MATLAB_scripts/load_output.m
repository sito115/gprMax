function allData = load_output(filenameArray)

if iscell(filenameArray)
    for iFile = 1:numel(filenameArray)
        fileName = filenameArray{iFile};
        [newData, fieldName] = fft_gprMaxOutput(pathname, fileName);
        allData.(fieldName) = newData.(fieldName);
    end
else
     [newData, fieldName] = fft_gprMaxOutput(pathname, filenameArray);
     allData.(fieldName) = newData.(fieldName);
end





