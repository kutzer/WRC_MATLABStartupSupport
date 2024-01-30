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
%           t0 - scalar value specifying a serial date number 
%                (e.g. t0 = now;)
%         exts - cell array of specific extensions to search for. If all 
%                extensions should be searched, use "exts = {}".  
%       spaths - cell array of search paths within the user directory. If
%                unspecified, the user directory is searched. 
%
%   Output(s)
%       fnames - cell array containing all filenames found
%
%   Example(s)
%
%       (1) Search for *.m and *.mat files created within the "Documents" 
%           and "Pictures" folder of the user profile after 12-noon on 
%           Jan. 29, 2024
%
%           t0 = datenum('29-Jan-2024 12:00:00');
%           exts = {'.m','.mat'};
%           spaths = {'Documents','Pictures'};
%           fnames = findNewFilesAfterTime(t0,exts,spaths);
%
%   Common search folders: 
%       Desktop, Documents, Downloads, Pictures, Videos
%
%   M. Kutzer, 29Jan2024, USNA

debug = false;

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
    %{
    psSearchPaths{1} = sprintf([...
        '# Specify the directory path\n',...
        '$directoryPath = ''%s''\n\n'],...
        path_b);
    %}
    psSearchPaths{1} = sprintf([...
        '$directoryPath = ''%s''\n'],...
        path_b);
else

    for i = 1:numel(spaths)
        
        % Define path to check
        tmp_path = fullfile(path_b,spaths{i});
        
        % Check for valid folder
        if isfolder( tmp_path )
            %{
            psSearchPaths{end+1} = sprintf([...
                '# Specify the directory path\n',...
                '$directoryPath = ''%s''\n\n'],...
                tmp_path);
            %}
            psSearchPaths{end+1} = sprintf([...
                '$directoryPath = ''%s''\n'],...
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
    %{
    psFilter = sprintf([...
        '# Specify the file extensions to filter\n',...
        '$fileExtensions = @(']);
    %}
    psFilter = sprintf([...
        '$fileExtensions = @(']);

    % Combine extensions
    n = numel(exts);
    for i = 1:n

        % Add extension
        psFilter = sprintf('%s''%s''',psFilter,exts{i});
        
        % Add comma
        if i < n
            psFilter = sprintf('%s,',psFilter);
        end

    end

    % PowerShell - End file extensions filter
    psFilter = sprintf('%s)\n',psFilter);

end

%% Define time bounds
% PowerShell - Define current time
%{
psCurrentTime = sprintf([...
    '# Calculate the current time\n',...
    '$currentDateTime = Get-Date\n']);
%}
psCurrentTime = sprintf([...
    '$currentDateTime = Get-Date\n']);

%% Define search
% PowerShell - Get files using specific filters
%{
psSearch = sprintf([...
    '# Get files in the specified directory and its subdirectories with specified extensions modified within the last 360 seconds\n',...
    '$recentFiles = Get-ChildItem -Path $directoryPath -Recurse | Where-Object {\n',...
    '    ($_.LastWriteTime -ge $startTime) -and ($fileExtensions -contains $_.Extension)\n',...
    '}\n\n']);
%}
psSearch = sprintf([...
    '$recentFiles = Get-ChildItem -Path $directoryPath -Recurse | Where-Object {',...
    '($_.LastWriteTime -ge $startTime) -and ($fileExtensions -contains $_.Extension)',...
    '}\n']);

%% Define display
%{
psDisplay = sprintf([...
    '# Display the list of recent files\n',...
    'foreach ($file in $recentFiles) {\n',...
    '    Write-Output "$($file.FullName)"\n',...
    '}\n\n']);
%}
psDisplay = sprintf([...
    'foreach ($file in $recentFiles) {',...
    'Write-Output "$($file.FullName)"',...
    '}\n']);

%% Define output file

% Define filename
fnameFileList = sprintf('newFileList_%s.txt',...
    datestr(now,'yyyymmddHHMMSS'));

%{
psOutputFile = sprintf([...
    '# Path to the output text file\n',...
    '$outputFilePath = ''%s''\n',...
    '\n',...
    '# Write file names to the text file\n',...
    '$recentFiles | ForEach-Object {\n',...
    '    $_.FullName | Out-File -Append -FilePath $outputFilePath\n',...
    '}\n'],fullfile(userpath,fnameFileList));
%}
psOutputFile = sprintf([...
    '$outputFilePath = ''%s''\n',...
    '$recentFiles | ForEach-Object {',...
    '$_.FullName | Out-File -Append -FilePath $outputFilePath',...
    '}\n'],fullfile(userpath,fnameFileList));

%% Find contents for each search directory
fnames = {};
for i = 1:numel(psSearchPaths)
    
    % PowerShell - Specify search directory
    psSearchPath = psSearchPaths{i};

    % Define elapsed time in seconds
    dt = ceil( (now-t0)*1e5 );

    % PowerShell - Define start time
    %{
    psStartTime = sprintf([...
        '# Time dt seconds ago\n',...
        '$startTime = $currentDateTime.AddSeconds(-%d)\n\n'],dt);
    %}
    psStartTime = sprintf([...
        '$startTime = $currentDateTime.AddSeconds(-%d)\n'],dt);

    % Build PowerShell Command
    psCommand = sprintf(repmat('%s',1,7),...
        psSearchPath,...    % (1) Search Path
        psFilter,...        % (2) Extension Filter
        psCurrentTime,...   % (3) Current Time
        psStartTime,...     % (4) Start Time
        psSearch,...        % (5) Search Files
        psDisplay,...       % (6) Display Files
        psOutputFile);      % (7) Create Output File
    
    % Display Command
    if debug
        dispBreak = repmat('-',1,60);
        fprintf('%s\n%s%s\n',dispBreak,psCommand,dispBreak);
    end

    %{
    % Send PowerShell Command
    %[a,msg] = system( sprintf('powershell -command "%s"',psCommand) );
    %disp(msg);
    %}

    % Send PowerShell Command in a single line
    psLines = regexp(psCommand,newline,'split');
    [~,msg] = system( sprintf('powershell -command "%s"',strjoin(psLines, ';')) );

    if debug
        disp(msg);
    end
        
    psOut = regexp(msg,newline,'split');
    fnames = [fnames,psOut];
end

%% Remove empty cells
tfEmpty = cellfun(@isempty,fnames);
fnames = fnames(~tfEmpty);







