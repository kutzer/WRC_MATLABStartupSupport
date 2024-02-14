function varargout = recoverStartupArchive
% RECOVERSTARTUPARCHIVE recovers file archives created by startup.m
%
%   recoverStartupArchive;
%
%   fname = recoverStartupArchive;
%
%   pname = recoverStartupArchive;
%
%   Input(s)
%       [NONE] - The user is prompted to provide date/time information to
%                find archived files in a specified range.
%
%   Output(s)
%       pname - [OPTIONAL] provides the folder path containing the
%               recovered files.
%
%   M. Kutzer, 13Feb2024, USNA

global uiInfo

varargout = {};

%% Internal debug flag
debug = true;
if debug
    fprintf('\nDEBUG: recoverStartupArchive.m\n');
end

%% Check input(s)
narginchk(0,0);

%% Find all mArc files
% Update user status
fprintf('Finding available archive files...');
% Find mArc files
[fnames,dateInfo] = findmArcFiles;
% Update user status
fprintf('[%d FILES FOUND]\n',numel(fnames));

% Debug
if debug
    for i = 1:numel(fnames)
        fprintf('\tFile %03d - "%s"\n',i,fnames{i});
        fprintf('\t%s%s\n',repmat(' ',1,11),string(dateInfo(i)));
    end
end

%% Convert to date-only values
dateOnly = dateshift(dateInfo,'Start','Day');

%% Convert to time-only values
timeOnly = timeofday(dateInfo);

%% Package in global variable
uiInfo.dateInfo = dateInfo;
uiInfo.dateOnly = dateOnly;
uiInfo.timeOnly = timeOnly;
uiInfo.fnames = fnames;

%% Define date range
dateOnly0 = dateshift(min(dateOnly)-1,'Start','Month');
dateOnlyF = dateshift(max(dateOnly)+1,'End','Month');

%% Define search dates
searchDates = dateOnly0:dateOnlyF;
tfDates = false( size(searchDates) );
for i = 1:numel(dateOnly)
    tfDates = tfDates | searchDates == dateOnly(i);
end
tfDates = ~tfDates;

excludeDates = searchDates(tfDates);

% Debug
if debug
    fprintf('\tDates Considered:\n');
    
    idx = 0;
    for i = 1:numel(searchDates)
        fprintf('\t\t%s - ',string(searchDates(i)));
        
        if searchDates(i) == dateOnly0
            fprintf('[LOWER LIMIT] - ');
        end
        
        if searchDates(i) == dateOnlyF
            fprintf('[UPPER LIMIT] - ');
        end
        
        if tfDates(i)
            fprintf('[EXCLUDED]\n');
        else
            idx = idx+1;
            fprintf('"%s"\n',fnames{idx});
        end
    end
end

%% Update user status
fprintf('Initializing recover archive UI...');

%% Prompt user for date/time range
% Create ui figure
wFig = 310;
hFig = 320;
uiInfo.fig = uifigure('Name','Select Archive Search Range','Position',[600,600,wFig,hFig]);
centerFigure(uiInfo.fig);

% Create date selection panel
wPnl0_d = 10;
hPnl0_d = 10;
wPnl_d = wFig - 2*wPnl0_d;
hPnl_d = hFig - 2*hPnl0_d;
uiInfo.pnl_d = uipanel(uiInfo.fig,'Title','Select Date','FontSize',12,...
    'FontWeight','bold','Position',[wPnl0_d,hPnl0_d,wPnl_d,hPnl_d]);

% Define date picker
uiInfo.date = uidatepicker(uiInfo.pnl_d,'Position',[10 245 150 25],...
    'ValueChangedFcn',@dateSelectCallback);
uiInfo.date.DisplayFormat = 'MM/dd/yyyy';
uiInfo.date.Limits = [min(searchDates),max(searchDates)];
uiInfo.date.DisabledDates = excludeDates;

% Create time selection panel
wPnl0_t = 10;
hPnl0_t = 65;
wPnl_t = wPnl_d - 2*wPnl0_t;
hPnl_t = hPnl_d - wPnl0_t - hPnl0_t;
uiInfo.pnl_t = uipanel(uiInfo.pnl_d,'Title','Select Time','FontSize',12,...
    'FontWeight','bold','Position',[wPnl0_d,hPnl0_d,wPnl_t,hPnl_t],...
    'Visible','off');

% Define time picker
uiInfo.time = uidropdown(uiInfo.pnl_t,'Position',[10,170,150,25],...
    'Items',{},'Visible','on','ValueChangedFcn',@timeSelectCallback);

% Define recover file button
wBtn0 = 10;
hBtn0 = 10;
wBtn = 150;
hBtn = 25;
uiInfo.button = uibutton(uiInfo.pnl_t,'Push','Text','Recover Files',...
    'FontWeight','bold','Position',[wPnl_t-wBtn-wBtn0,hBtn0,wBtn,hBtn],...
    'ButtonPushedFcn',@recoverFileCallback);

drawnow

%% Update user status
fprintf('[DONE]\n');

%% Wait until the figure is closed
uiwait(uiInfo.fig);

%% Package output(s)
if nargout > 0
    varargout{1} = uiInfo.pname;
end

end

%% Internal functions
% -------------------------------------------------------------------------
function dateSelectCallback(src,event)

global uiInfo

fprintf('Date Changed\n')

% Isolate selected date
uiInfo.dateSelect = src.Value;

% Find index of selected date(s)
uiInfo.tfDateSelect = uiInfo.dateOnly == uiInfo.dateSelect;

% Define times for given date
uiInfo.timeOptions = uiInfo.timeOnly(uiInfo.tfDateSelect);

% Define time selection
uiInfo.timeSelect = uiInfo.timeOptions(1);

% Update panel
uiInfo.pnl_t.Visible = 'on';

% Update dropdown
uiInfo.time.Items = string(uiInfo.timeOptions);

end

% -------------------------------------------------------------------------
function timeSelectCallback(src,event)

global uiInfo

fprintf('Time Changed\n')

uiInfo.timeSelect = duration( src.Value );

end

% -------------------------------------------------------------------------
function recoverFileCallback(src,event)

global uiInfo

fprintf('Recover File\n')

% Down-select files by date
fnames = uiInfo.fnames(uiInfo.tfDateSelect);
fdatetimes = uiInfo.dateInfo(uiInfo.tfDateSelect);

% Define times for given date
uiInfo.tfTimeSelect = uiInfo.timeOptions == uiInfo.timeSelect;
fnames = fnames(uiInfo.tfTimeSelect);
fdatetimes = fdatetimes(uiInfo.tfTimeSelect);

% Copy file
source = fnames{1};
[~,bname,~] = fileparts(source);
destination = fullfile(userpath,[bname,'.zip']);
[tf,msg,msgID] = copyfile(source,destination);
% -> Check for issue copying file
if ~tf
    error([...
        'Unable to copy file:\n',...
        '\tFrom: "%s"\n',...
        '\t  To: "%s"\n',...
        '%s'],source,destination,msg);
end

% Unzip file
unzipPath = cleanUnzip(destination);

% Consolidate files into folder
% -> Define source
source = unzipPath;
% -> Define destination
pname = sprintf('recoveredFiles_%s',string(fdatetimes(1),'yy-MM-dd_HHmmss'));
destination = fullfile(userpath,pname);
% -> Consolidate files
consolidateFiles(source,destination);

% Delete unzip directory
[tf,msg,msgID] = rmdir(unzipPath,'s');
if ~tf
    fprintf([...
        'Unable to remove the following directory:\n',...
        '\t%s\n',...
        '%s\n]'],unzipPath,msg);
end

% Open folder location
%winopen(destination)
cmdStr = sprintf('start explorer "%s"',destination);
system( cmdStr );

% Package output(s)
uiInfo.pname = destination;

% Delete figure
delete(uiInfo.fig);

end