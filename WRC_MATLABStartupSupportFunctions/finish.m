function finish
% FINISH automatically runs when MATLAB is closed to close all preview
% windows, the camera calibrator, etc.
%
%   See also startup recoverStartupArchive
%
%   M. Kutzer, 14Apr2026, USNA


%% Define global variable(s)
global startupInfo %currentFolderTimer

%% Check username
switch lower( getenv('username') )
    case 'student'
        % Run finish function
    case 'ew452'
        % Ignore startup
        return
    otherwise
        fprintf([...
            'Actionable "finish.m" code only runs on the "Student" account\n',...
            '-> Debugging\n']);
        startupInfo.DebugOn = true;
end

%% Close windows
% ---- Close MATLAB Camera Calibrator ----
if startupInfo.DebugOn
    fprintf('\t-> Closing camera calibrator\n')
end
closeCameraCalibrator;

% ---- Close all previews ----
if startupInfo.DebugOn
    fprintf('\t-> Closing previews\n')
end
try
    killPreviews;
catch ME
    fprintf('Unable to close all previews: \n\n"%s"\n',ME.message);
end

% ---- Close all figures ----
if startupInfo.DebugOn
    fprintf('\t-> Closing figures\n')
end
try
    figs = findall(0,'Type','Figure');
    fNames = get(figs,'Name');
    tf = matches(fNames,'startup.m');
    delete(figs(~tf));
    drawnow
catch ME
    fprintf('Unable to close all open figures: \n\n"%s"\n',ME.message);
end

%% Trigger close request function for startup.m figure
if startupInfo.DebugOn
    fprintf('\t-> Closing startup.m figure\n')
end