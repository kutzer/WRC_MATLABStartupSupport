function startup
% STARTUP automatically runs at startup to clear contents from the defaultr
% folder location on close and package new files created during a MATLAB
% session.
%
%   NOTES:
%       (1) This function is only fully supported on Windows OS. Not all
%           functionality extends to other operating systems.
%       (2) This function is currently username-specific and will only run
%           on accounts with the username "Student."
%
%   See also recoverStartupArchive
%
%   M. Kutzer, 17Jan2024, USNA

% Updates
%   27Feb2024 - Updated "filenames" initialization to {}.
%   19Mar2024 - Updated to close camera calibrator
%   16Apr2024 - Updated to close all open figures and ignore EW452 login

%% Define global variable(s)
global startupInfo %currentFolderTimer

%startupInfo.CurrentFolders = {};
%startupInfo.FolderContents = {};
%startupInfo.NewFilenames   = {};

startupInfo.DebugOn     = false;
startupInfo.StartupTime = now;

%% Check username
startupInfo.DebugOn = false;
switch lower( getenv('username') )
    case 'student'
        % Run startup function
    case 'ew452'
        % Ignore startup
        return
    otherwise
        fprintf([...
            'Actionable "startup.m" code only runs on the "Student" account\n',...
            '-> Debugging\n',...
            '-> Run "delete(gcf)" to disable file packaging on close.\n\n']);
        startupInfo.DebugOn = true;
end
    
%% Close all open documents
if ~startupInfo.DebugOn
    
    % TODO - Do this more elegantly
    for i = 1:10
        % Add some delay before closing the MATLAB editor
        drawnow
        pause(0.05);
        
        % Close MATLAB editor
        try
            closeMatlabEditor(true);
            break
        catch ME
            %fprintf('Unable to close editor.\n');
        end
    end
    
end

%% Change current folder to default working path
if ~startupInfo.DebugOn
    cd( userpath );
end

%% Get initial directory
wd0 = pwd;
wd1 = tempdir;
zipName = sprintf('archive_%s',datestr(now,'yy-mm-dd_hhMMss'));

%% Find contents of default working path
d = dir(wd0);
filenames = {};%cell(1,numel(d)-2);
j = 0;
for i = 1:numel(d)
    switch d(i).name
        case '.'
            % Ignore
        case '..'
            % Ignore
        case 'apriltag-imgs'
            % Ignore
        case 'apriltag-imgs_path.mat'
            % Ignore
        otherwise
            j = j+1;
            filenames{j} = fullfile(wd0,d(i).name);
    end
end

%% Zip contents & change file extension
tfArchiveMade = false;
if ~isempty(filenames)
    try
        % Zip contents
        zip(fullfile(wd1,zipName),filenames);
        % Change file extension
        zip2mArc(wd1,zipName);
        % Change archive flag
        tfArchiveMade = true;
    catch ME
        fprintf([...
            'Unable to create archive file: "%s"\n',...
            '\t Archive Name: "%s"\n',...
            '\tArchive Files:\n'],ME.message,fullfile(wd1,zipName));
        for i = 1:numel(filenames)
            fprintf('\t\tIs File: %d - "%s"\n',isfile(filenames{i}),filenames{i});
        end
    end
end

%% Delete directory contents
if ~startupInfo.DebugOn
    if tfArchiveMade
        deleteFiles(filenames);
    end
end

%% Check for other Windows users
try
    [allUsers,currentUser] = getSignedInUsers;
    if numel(allUsers) > 1
        str = '';
        for i = 1:numel(allUsers)
            if ~matches(allUsers{i},currentUser)
                str = sprintf('\t(%02d) %s"%s"\n',i,str,allUsers{i});
            end
        end
        emphStr = repmat('-',1,58);
        fprintf(2,[...
            '\n',...
            '%s\n!!!!! Other users are logged in to this workstation !!!!!!\n%s\n',...
            'Other usernames currently logged in:\n',...
            '%s\n',...
            ' -> Ask your instructor to log out of these accounts or\n',...
            '    consider restarting the computer before proceeding.\n',...
            '%s\n\n'],emphStr,emphStr,str,emphStr);
    end
catch ME
    fprintf('Unable to execute getSignedInUsers:\n\t"%s"\n',ME.message);
end

%% Check login time 
try
    userInfo = getUserInfo;
    usernames = {userInfo(:).Username};
    tfNames = matches(usernames,currentUser);
    if nnz(tfNames) == 1
        userInfo = userInfo(tfNames);
        
        logonTime = userInfo(1).LogonTime;
    end
catch ME
    fprintf('Unable to execute getUserInfo:\n\t"%s"\n',ME.message);
    logonTime = [];
end

% TODO - do a better job of this hard-coded time between classes
dt = hours(2);  % Limit duration to a 2-hour period
if isdatetime(logonTime)
    startupTime = datetime(startupInfo.StartupTime,'ConvertFrom','datenum');
    if (startupTime - logonTime) < dt
        % Use logon time for file search
        startupInfo.StartupTime = datenum(logonTime);
    elseif (startupTime - logonTime) >= dt
        % Warn user
        fprintf(2,[...
            '\nThis username has been logged in for %sours.\n',...
            ' -> Be sure to log out when you finish work!\n',...
            ' -> If this persists, consider logging out and logging back on before starting work.\n' ...
            '    Doing so will save time when compiling files when MATLAB closes.\n'],...
            string((startupTime - logonTime),"h","fr_FR"));
        % Adjust time
        startupInfo.StartupTime = datenum(startupTime - dt);
    end
        
end

%% Create background figure
fig = figure('Name','startup.m','Tag','startup.m','Units','Normalized',...
    'Position',[0.10,0.85,0.15,0.05],'MenuBar','None',...
    'NumberTitle','off','Resize','off','Toolbar','None',...
    'CloseRequestFcn',@closeFigureCallback,...
    'Visible','off','HandleVisibility','callback');

if startupInfo.DebugOn
    % Show figure
    set(fig,'Visible','on','HandleVisibility','on');
end

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
% This code is replaced by "findNewFilesAfterTime.m"
%{
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
%}

end

%% Internal functions
% -------------------------------------------------------------------------
%{
function currentFolderCallbackStart(src,event)

global startupInfo

% Debug
fprintf('Running StartFunction\n');

try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    fprintf('Error in startup.m -> currentFolderCallbackStart.m\n\t%s\n',...
        ME.message);
end

end
%}
% -------------------------------------------------------------------------
%{
function currentFolderCallbackStop(src,event)

global startupInfo

% Debug
fprintf('Running StopFcn\n');

try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    fprintf('Error in startup.m -> currentFolderCallbackStop.m\n\t%s\n',...
        ME.message);
end

% Zip new contents
if ~isempty(startupInfo.NewFilenames)
    % Zip contents
    % TODO - deconflict common filenames
    zipName = sprintf('currentWork_%s',datestr(now,'yy-mm-dd_hhMMss'));
    zip(fullfile(userpath,zipName),startupInfo.NewFilenames);

    % Open file explorer to user path location
    winopen( userpath );

    % Open web browser to Google Drive
    url = 'https://accounts.google.com/v3/signin/identifier?continue=http%3A%2F%2Fdrive.google.com%2F%3Futm_source%3Den&ec=asw-drive-hero-goto&ifkv=ASKXGp2L3r8s3HbcyTQP23BYzP01WVT-npzhcdR7rNPMy7RjUi1cAMKaV6FJRE2hpuRhHiDLIIYpQQ&ltmpl=drive&passive=true&service=wise&usp=gtd&utm_campaign=web&utm_content=gotodrive&utm_medium=button&flowName=GlifWebSignIn&flowEntry=ServiceLogin&dsh=S1258750083%3A1705607539416545&theme=glif';
    web(url,'-browser');
end

end
%}
% -------------------------------------------------------------------------
%{
function currentFolderCallback(src,event)

global startupInfo

% Debug
fprintf('Running TimerFcn\n');

try
    startupInfo = appendNewFiles(startupInfo);
catch ME
    fprintf('Error in startup.m -> currentFolderCallback.m\n\t%s\n',...
        ME.message);
end

end
%}
% -------------------------------------------------------------------------
%{
function currentFolderCallbackError(src,event)

global startupInfo

% Debug
fprintf('Running ErrorFcn\n');

end
%}
% -------------------------------------------------------------------------
function closeFigureCallback(src,event)
%{
global currentFolderTimer

% Debug
fprintf('Figure closed\n')


try  
    stop( currentFolderTimer );
catch ME
    fprintf('Error in startup.m -> closeFigureCallback.m\n\t%s\n',...
        ME.message);
end
%}
global startupInfo

% ---- Close MATLAB Camera Calibrator ----
try
    closeCameraCalibrator;
catch ME
    fprintf('Unable to close camera calibrator: "%s"\n',ME.message);
end

% ---- Close all figures ----
try
    figs = findall(0,'Type','Figure');
    fNames = get(figs,'Name');
    tf = matches(fNames,'startup.m');
    delete(figs(~tf));
    drawnow
catch ME
    fprintf('Unable to close all open figures: "%s"\n',ME.message);
end

% ---- Package new files ----
try
    % Define search start time
    t0 = startupInfo.StartupTime;

    % Define search file extensions
    exts = {... % MATLAB Formats
        '.m','.mat','.fig','.asv',...
        ...     % Image Formats
        '.bmp','.eps','.emf','.jpg','.pcx','pbm','.pdf','.png','.ppm',...
        '.svg','.tif',...
        ...     % Video Formats
        '.asf','.asx','.avi','.m4v','.mj2','.mov','.mp4','.mpg','.wmv',...
        ...     % Other Formats
        '.txt','.doc','.docx','.ppt','.pptx','.xls','.xlsx'};

    % Define search paths
    spaths = {'Desktop','Documents','Downloads','Music','Pictures','Videos'};

    % Find new files
    gpTimer = gifProcessWait(0,'Finding new files created...');
    pause(0.5);
    fnames = findNewFilesAfterTime(t0,exts,spaths);
    gifProcessWait(gpTimer);

    % Package files
    % -> Define folder to pack files
    pack_pname = fullfile(userpath,...
        sprintf('savedFiles_%s',datestr(now,'yyyymmddHHMMSS')) );
    % -> Pack files
    [newFnames,oldFnames] = packageFiles(fnames,pack_pname);

    % Zip packed files
    zip( [pack_pname,'.zip'],pack_pname );

    % Delete pack directory
    deleteFiles( {pack_pname} );

    % Remove files
    if ~startupInfo.DebugOn
        % Delete found files
        deleteFiles(oldFnames);
    end

    % Open incognito chrome browser window to Google Drive
    cmdStr = 'start chrome.exe --incognito';
    urlStr = 'https://accounts.google.com/v3/signin/identifier?hl=en&ifkv=ASKXGp30QkpdUTispLLCLftBiYkzlX40npL-ZuFbsyozU8RQysvILxbGGX2ZY46uW_tATjyLzXwmjQ&service=writely&flowName=GlifWebSignIn&flowEntry=ServiceLogin&dsh=S-653431847%3A1706728260630640&theme=glif';
    system( sprintf('%s "%s"',cmdStr,urlStr) );

    % Wait for window to open
    drawnow;
    pause(0.5);

    % Open zip file location
    %winopen(userpath)
    cmdStr = sprintf('start explorer "%s"',userpath);
    system( cmdStr );
catch ME
    delete(src);
    ME.throw;
end

delete(src);

end
