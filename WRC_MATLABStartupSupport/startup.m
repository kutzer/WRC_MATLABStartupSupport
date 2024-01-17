function startup
% STARTUP automatically runs at startup to clear contents from the default
% folder location on close.
%
%   M. Kutzer, 17Jan2024, USNA

%% Close all open documents
% References:
%   [1] Luis Mendo, May 23, 2017
%       https://stackoverflow.com/questions/28119360/how-to-close-one-or-all-currently-open-matlab-m-files-from-matlab-command-pr

closeUnsaved = true; % Close unsaved documents

% Acccess the editor Java object.
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;            % desktop object
jEditor = desktop.getGroupContainer('Editor').getTopLevelAncestor; % editor object

% Get the number of open documents
D = jEditor.getGroup.getDocumentCount;

% Programmatically make the editor the window in front
jEditor.requestFocus;

% Programmatically send "ALT-F4" keystroke for each open document
%  - For closing unsaved, programmatically send "N" to close without saving
robot = java.awt.Robot;
for n = 1:D
    robot.keyPress(java.awt.event.KeyEvent.VK_ALT);     % press "ALT"
    robot.keyPress(java.awt.event.KeyEvent.VK_F4);      % press "F4"
    robot.keyRelease(java.awt.event.KeyEvent.VK_F4);    % release "F4"
    robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);   % release "ALT"
    if closeUnsaved
        robot.keyPress(java.awt.event.KeyEvent.VK_N);   % press "N"
        robot.keyRelease(java.awt.event.KeyEvent.VK_N); % release "N"
    end
end

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
    movefile(...
        fullfile(wd1,[zipName,'.zip']),...
        fullfile(wd1,[zipName,'.mArc']));
end

%% Delete directory contents
for i = 1:numel(filenames)
    if isfolder(filenames{i})
        % Remove folder
        rmdir(filenames{i},'s');
    else
        % Remove file
        delete(filenames{i});
    end
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
