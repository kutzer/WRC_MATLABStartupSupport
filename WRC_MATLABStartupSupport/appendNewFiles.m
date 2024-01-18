function [fInfo] = appendNewFiles(fInfo)

newDir = pwd;
if isempty(fInfo.CurrentFolders)
    % Save current folder
    fInfo.CurrentFolders{1} = newDir;
    % Define all file/folder names within current folder
    dd = dir(newDir);
    fInfo.FolderContents{1} = {dd.name};
else
    if any( matches(fInfo.CurrentFolders,newDir) )
        % Folder has already been added, compare contents

        % Find folder index
        bin = matches(fInfo.CurrentFolders,newDir);

        % Find current folder contents
        dd = dir(newDir);
        newFolderContents = {dd.name};

        % Check current folder contents
        for ii = 1:numel(newFolderContents)
            if ~any( matches(fInfo.FolderContents{bin},newFolderContents{ii}) )
                % Append new filenames
                fInfo.NewFilenames{end+1} = fullfile(newDir,newFolderContents{ii});
                % Add new filename to existing list
                fInfo.FolderContents{bin}{end+1} = newFolderContents{ii};
            end
        end
    else
        % Folder is new, add to the list

        ii = numel(fInfo.CurrentFolders) + 1;
        % Save current folder
        fInfo.CurrentFolders{ii} = newDir;
        % Define all file/folder names within current folder
        dd = dir(newDir);
        fInfo.FolderContents{ii} = {dd.name};
    end
end
