function startup
% STARTUP automatically runs at startup to clear contents from the default
% folder location on close.
%
%   M. Kutzer, 17Jan2024, USNA

%global startupCurrentFolderTracker

%% Check username
switch lower( getenv('username') )
    case 'student'
        % Run startup function
    otherwise
        fprintf('Actionable "startup.m" code only runs on the "Student" account\n');
        return
end

%% Close all open documents
closeMatlabEditor(true);

%% Change current folder to default working path
cd( userpath );

%% Get initial directory
wd0 = userpath;
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
deleteFiles(filenames);

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
startupCurrentFolders = {};
startupFolderContents = {};
startupNewFilenames = {};
%

% Internal functions
    function currentFolderCallbackStart(src,event)
        fprintf('I am StartFunction\n');
        appendNewFiles
    end

    function currentFolderCallbackStop(src,event)
        fprintf('I am StopFcn\n');
        appendNewFiles
    end

    function currentFolderCallback(src,event)
        fprintf('I am TimerFcn\n');
        appendNewFiles
        startupNewFilenames
    end

    function currentFolderCallbackError(src,event)
        fprintf('I am ErrorFcn\n');
    end

    function appendNewFiles
        newDir = pwd;
        if isempty(startupCurrentFolders)
            % Save current folder
            startupCurrentFolders{1} = newDir;
            % Define all file/folder names within current folder
            dd = dir(newDir);
            startupFolderContents{1} = {dd.name};
        else
            if any( matches(startupCurrentFolders,newDir) )
                % Folder has already been added, compare contents
                
                % Find folder index
                bin = matches(startupCurrentFolders,newDir);
                
                % Find current folder contents
                dd = dir(newDir);
                newFolderContents = {dd.name};
                
                % Check current folder contents
                for ii = 1:numel(newFolderContents)
                    if ~any( matches(startupFolderContents{bin},newFolderContents{ii}) )
                        startupNewFilenames{end+1} = fullfile(newDir,newFolderContents{ii});
                    end
                end
            else
                % Folder is new, add to the list
                
                ii = numel(startupCurrentFolders) + 1;
                % Save current folder
                startupCurrentFolders{ii} = newDir;
                % Define all file/folder names within current folder
                dd = dir(newDir);
                startupFolderContents{ii} = {dd.name};
            end
        end
    end

end