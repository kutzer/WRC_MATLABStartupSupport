function [newFnames,oldFnames] = packageFiles(fnames,pname)
% PACKAGEFILES copies all specified files into a specified folder. Unique
% instances of filepaths are preserved for all files.
%
%   newFnames = packageFiles(fnames,pname)
%
%   Input(s)
%       fnames - cell array containing full file or path names
%        pname - string specifying new, full path name
%
%   Output(s)
%       newFnames - cell array containing the full file path for each
%                   copied file
%
%   M. Kutzer, 31Jan2024, USNA

%% Check input(s)
narginchk(2,2);

% Check filenames
tf = isfile(fnames);
if nnz(~tf) > 0

    % Display status to user
    fprintf('Ignoring files:\n')
    for i = find(~tf)
        fprintf('\t"%s"\n',fnames{i});
    end

    % Remove bad filenames
    fnames = fnames(tf);

end

% Check path name
if isfolder(pname)
    warning('Specified path already exists.');
end

%% Make new directory
[status,msg] = mkdir(pname);

if ~status
    error('Unable to create %s:\n%s\n',pname,msg);
end

%% Remove common file path(s)
[rFnames,commonPname] = removeCommonPath(fnames);

%% Create new directories
for i = 1:numel(rFnames)

    % Isolate file path
    [fpname,~,~] = fileparts(rFnames{i});
    
    % Create new, full path
    nPname = fullfile(pname,fpname);

    % Check if path already exists
    if ~isfolder( nPname )

        % Create directory
        [status,msg] = mkdir(nPname);

        if ~status
            % Unable to create directory
            fprintf([...
                'Unable to create directory:',...
                '\t%s\n',...
                '\n',...
                '%s\n'],nPname,msg);
        end

    end
end

%% Copy files
newFnames = {};
oldFnames = {};

for i = 1:numel(rFnames)
    
    % Define source
    source = fullfile(commonPname,rFnames{i});

    % Define destination
    destination = fullfile(pname,rFnames{i});

    % Check if file exists
    if ~isfile( source )
        fprintf('The following file does not exist:\n\t%s\n',source);
        continue
    end

    % Copy file
    [status,msg] = copyfile(source,destination);

    % Check for error(s)
    if ~status
        fprintf([...
            'Unable to copy:',...
            '\t     Source: %s\n',...
            '\tDestination: %s\n',...
            '\n',...
            '%s\n'],pname,msg);
        continue
    end

    newFnames{end+1} = destination;
    oldFnames{end+1} = source;
end
