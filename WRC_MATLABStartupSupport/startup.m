function startup
% STARTUP automatically runs at startup to clear contents from the default
% folder location on close.
%
%   M. Kutzer, 17Jan2024, USNA

global startupInfo
startupInfo.CurrentFolders = {};
startupInfo.FolderContents = {};
startupInfo.NewFilenames = {};

%% Check username
debugOn = false;
switch lower( getenv('username') )
    case 'student'
        % Run startup function
    otherwise
        fprintf('Actionable "startup.m" code only runs on the "Student" account\n -> Debugging\n');
        debugOn = true;
end

%% Close all open documents
if ~debugOn
    closeMatlabEditor(true);
end

%% Change current folder to default working path
if ~debugOn
    cd( userpath );
end

%% Get initial directory
wd0 = pwd;
wd1 = tempdir;
zipName = sprintf('archive_%s',datestr(now,'yy-mm-dd_hhMMss'));

%% Find contents of default working path
d = dir(wd0);
filenames = cell(1,numel(d)-2);
j = 0;
for i = 1:numel(d)
    switch d(i).name
        case '.'
            % Ignore
        case '..'
            % Ignore
        otherwise
            j = j+1;
            filenames{j} = fullfile(wd0,d(i).name);
    end
end

%% Zip contents & change file extension
if ~isempty(filenames)
    % Zip contents
    zip(fullfile(wd1,zipName),filenames);
    % Change file extension
    zip2mArc(wd1,zipName);
end

%% Delete directory contents
if ~debugOn
    deleteFiles(filenames);
end

%% Create background figure
fig = figure('Name','startup.m','Tag','startup.m','Units','Normalized',...
    'Position',[0.10,0.85,0.15,0.05],'MenuBar','None',...
    'NumberTitle','off','Resize','off','Toolbar','None');

% Create panel
pnl = uipanel('Parent',fig,'Units','Normalized',...
    'Position',[0,0,1,1],'Title','startup.m',...
    'TitlePosition','CenterTop','Tag','startup.m');

% Create text
cnt = uicontrol('Parent',pnl,'Style','Text','Units','Normalized',...
    'Position',[0,0,1,1],'FontUnits','Normalized','FontSize',0.15,...
    'HorizontalAlignment','center','Tag','startup.m',...
    'String',sprintf('wd0: %s\nwd1: %s\n%s',wd0,wd1,[zipName,'.mArc']));

%% Create timer-based current directory tracking
currentFolderTimer = timer('StartDelay',1,'Period',1,...
    'TasksToExecute',15,'BusyMode','drop','ExecutionMode','fixedRate',...
    'Name','Current Folder Tracker (startup.m)',...
    'Tag','Current Folder Tracker (startup.m)',...
    'ObjectVisibility','on');

currentFolderTimer.StartFcn = @currentFolderCallbackStart;
currentFolderTimer.StopFcn = @currentFolderCallbackStop;
currentFolderTimer.TimerFcn = @currentFolderCallback;
currentFolderTimer.TimerFcn = @currentFolderCallback;
currentFolderTimer.ErrorFcn = @currentFolderCallbackError;

start(currentFolderTimer)


end

%% Internal functions
% -------------------------------------------------------------------------
function currentFolderCallbackStart(src,event)
global startupInfo

fprintf('I am StartFunction\n');
try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    ME
end

end

% -------------------------------------------------------------------------
function currentFolderCallbackStop(src,event)
global startupInfo

fprintf('I am StopFcn\n');
try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    ME
end

end

% -------------------------------------------------------------------------
function currentFolderCallback(src,event)
global startupInfo

fprintf('I am TimerFcn\n');
try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    ME
end

end

% -------------------------------------------------------------------------
function currentFolderCallbackError(src,event)
global startupInfo

fprintf('I am ErrorFcn\n');

end
