function [fInfo] = appendNewFiles(fInfo)

% system( 'powershell -command "Get-ChildItem -Recurse | Where-Object { $_.LastWriteTime -ge "01/22/2024" }"')
% https://stackoverflow.com/questions/60114912/executing-a-powershell-command-from-matlab
% https://stackoverflow.com/questions/17616045/find-files-on-windows-modified-after-a-given-date-using-the-command-line

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
                % -> File is new

                % Append new filenames
                fInfo.NewFilenames{end+1} = fullfile(newDir,newFolderContents{ii});
                % Add new filename to existing list
                fInfo.FolderContents{bin}{end+1} = newFolderContents{ii};

            elseif dd.datenum > fInfo.StartupTime
                % -> File has been updated

                if ~any( matches(fInfo.))

                end
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

