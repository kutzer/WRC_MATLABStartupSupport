function finish
% FINISH automatically runs when MATLAB is closed to close all preview
% windows, the camera calibrator, etc.
%
%   See also startup recoverStartupArchive
%
%   M. Kutzer, 14Apr2026, USNA


% ---- Close MATLAB Camera Calibrator ----
try
    closeCameraCalibrator;
catch ME
    fprintf('Unable to close camera calibrator: "%s"\n',ME.message);
end

% ---- Close all previews ----
killPreviews;

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