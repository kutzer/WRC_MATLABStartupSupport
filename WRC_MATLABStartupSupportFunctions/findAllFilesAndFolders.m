function [fNames,fTypes] = findAllFilesAndFolders(pName,pIgnore)
% FINDALLFILESANDFOLDERS recursively finds all files and folders within a 
% specified path.
%
%   fNames = findAllFilesAndFolders(pName)
%
%   fNames = findAllFilesAndFolders(pName,pIgnore)
%
%   [fNames,fTypes] = findAllFilesAndFolders(___)
%
%   Input(s)
%         pName - string defining path to search
%       pIgnore - cell array containing folder names to ignore. Note that 
%                 '.' and '..' folder names are ignored automatically.
%
%   Output(s)
%       fNames - cell array defining all files and folders found. These
%                files ignore '.' and '..' directories.
%       fTypes - structured array with fields matching specific file types
%                found.
%
%   Example(s)
%       pName = 'C:\Users\Student';
%       pIgnore = {'AppData','apriltag-imgs'}
%       [fNames,fTypes] = findAllFilesAndFolders(pName,pIgnore);
%
%   M. Kutzer, 01Feb2024, USNA

%% Check input(s)
narginchk(1,2);

if ~isfolder(pName)
    error('The path "%s" is not valid.');
end

if nargin < 2
    pIgnore = {'.','..'};
else
    pIgnore = [{'.','..'},pIgnore];
end

%% Find all files and folders contained within the specified path
fNames = {};
fTypes = struct;

pt_chk{1} = pName;
tf_chk(1) = true;
while true
    
    for i = find(tf_chk)
        
        % Mark path as checked
        tf_chk(i) = false;
        
        % Find path contents 
        d = dir( pt_chk{i} );
        
        % User update
        fprintf('Directory: "%s"\n',pt_chk{i});
        for j = 1:numel(d)
            
            % Get full file name
            fName = fullfile( d(j).folder,d(j).name );
 
            % Add directories to check list
            if d(j).isdir
                
                % Check for ignored folders
                if any( matches(pIgnore,d(j).name) )
                    fprintf('\tFolder - IGNORED: "%s"\n',d(j).name);
                    continue
                end
                
                % Append check file
                pt_chk{end+1} = fName;
                tf_chk(end+1) = true;
                
                % Append full path name
                fNames{end+1} = fName;
                % User update
                fprintf('\tFolder -   ADDED: "%s"\n',d(j).name);
                
            else
                % Append full path name
                fNames{end+1} = fName;
                % User update
                fprintf('\t  File -   ADDED: "%s"\n',d(j).name);
                
                % Find file type
                [~,~,ext] = fileparts(fName);
                
                % Append file type
                fldName = matlab.lang.makeValidName(...
                    ext(2:end),'ReplacementStyle','hex');
                if isfield(fTypes,fldName)
                    fTypes.(fldName){end+1} = fName;
                else
                    fTypes.(fldName) = {fName};
                end
                
            end
        end
        
    end
    
    % Create break condition
    if nnz(tf_chk) == 0
        break
    end
    
end
                
        