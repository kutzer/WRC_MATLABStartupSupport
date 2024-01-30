function fnames = findNewFilesAfterTime(t0,exts,spaths)
% FINDNEWFILESAFTERTIME finds files created after a time specified by a
% serial date number. 
%
%   fnames = findNewFilesAfterTime(t0)
%
%   fnames = findNewFilesAfterTime(t0,exts)
%
%   fnames = findNewFilesAfterTime(t0,exts,spaths)
%
%   Input(s)
%           t0 - scalar value specifying a serial date number (e.g. t0 = now;)
%         exts - cell array of specific extensions to search for. If
%                unspecified, all files are returned. 
%       spaths - cell array of search paths within the user directory
%
%   Output(s)
%       fnames - cell array containing all filenames found

%% Check input(s)
narginchk(1,3);

if t0 > now
    error('Specified serial date number is in the future.');
end

if nargin < 2
    exts = {};
end

if nargin < 3
    spaths = {};
end

if ~ispc
    error('This function requires a Windows OS.');
end

%% Define user profile directory

% Define base directory
%   -> e.g. C:\Users\[USERNAME]
path_b = getenv('USERPROFILE');

%% Define search paths
psSearchPaths = {};
if isempty(spaths)
    psSearchPaths{1} = sprintf([...
        '# Specify the directory path\n',...
        '$directoryPath = "%s"\n\n'],...
        path_b);
else

    for i = 1:numel(spaths)
        
        % Define path to check
        tmp_path = fullfile(path_b,spaths{i});
        
        % Check for valid folder
        if isfolder( tmp_path )
            psSearchPaths{end+1} = sprintf([...
                '# Specify the directory path\n',...
                '$directoryPath = "%s"\n\n'],...
                tmp_path);
        else
            fprintf('"%s" is not a valid directory\n',tmp_path);
        end

    end

    if isempty(psSearchPaths)
        error('No valid directories specified.');
    end
end

%% Define file extension filter
psFilter = '';
if ~isempty(exts)
    
    % PowerShell - Specify the file extensions to filter
    psFilter = sprintf([...
        '# Specify the file extensions to filter\n',...
        '$fileExtensions = @(']);
   
    % Combine extensions
    n = numel(exts);
    for i = 1:n

        % Add extension
        psFilter = sprintf('%s"%s"',psFilter,exts{i});
        
        % Add comma
        if i < n
            psFilter = sprintf('%s,',psFilter);
        end

    end

    % PowerShell - End file extensions filter
    psFilter = sprintf('%s)\n\n',psFilter);

end

%% Define time bounds
% PowerShell - Define current time
psCurrentTime = sprintf([...
    '# Calculate the current time\n',...
    '$currentDateTime = Get-Date\n']);

%% Define search
% PowerShell - Get files using specific filters
psSearch = sprintf([...
    '# Get files in the specified directory and its subdirectories with specified extensions modified within the last 360 seconds\n',...
    '$recentFiles = Get-ChildItem -Path $directoryPath -Recurse | Where-Object {\n',...
    '    ($_.LastWriteTime -ge $startTime) -and ($fileExtensions -contains $_.Extension)\n',...
    '}\n\n']);

%% Define display
psDisplay = sprintf([...
    '# Display the list of recent files\n',...
    'foreach ($file in $recentFiles) {\n',...
    '    Write-Output "$($file.FullName)"\n',...
    '}\n']);

%% Find contents for each search directory
for i = 1:numel(psSearchPaths)
    
    % PowerShell - Specify search directory
    psSearchPath = psSearchPaths{i};

    % Define elapsed time in seconds
    dt = ceil( (now-t0)*1e5 );

    % PowerShell - Define start time
    psStartTime = sprintf([...
        '# Time dt seconds ago\n',...
        '$startTime = $currentDateTime.AddSeconds(-%d)\n\n'],dt);

    % Build PowerShell Command
    psCommand = sprintf('powershell -command "%s%s%s%s%s%s"',...
        psSearchPath,...    % (1) Search Path
        psFilter,...        % (2) Extension Filter
        psCurrentTime,...   % (3) Current Time
        psStartTime,...     % (4) Start Time
        psSearch,...        % (5) Search Files
        psDisplay);         % (6) Display Files
    
    % Display Command
    dispBreak = repmat('-',1,60);
    fprintf('%s\n%s\n%s\n',dispBreak,psCommand,dispBreak);

    % Send PowerShell Command
    [a,msg] = system(psCommand)

    disp(msg);
end

fnames = msg;









