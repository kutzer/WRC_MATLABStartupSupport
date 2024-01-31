function deleteFiles(filenames)
% DELETEFOLDERCONTENTS deletes all files specified in a cell array.
%   deleteFolderContents(pname)
%
%   Input(s)
%       filenames - cell array containing filenames and/or foldernames
%
%   M. Kutzer, 18Jan2024, USNA

%% Check for empty input
if isempty(filenames)
    return
end

%% Delete all files and/or folders
for i = 1:numel(filenames)
    if isfolder(filenames{i})
        % Remove folder
        rmdir(filenames{i},'s');
    elseif isfile(filenames{i})
        % Remove file
        delete(filenames{i});
    else
        fprintf('The following file does not exist:\n\t%s\n',filenames{i});
    end
end