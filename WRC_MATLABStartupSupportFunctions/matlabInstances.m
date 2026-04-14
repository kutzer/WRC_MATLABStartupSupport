function n = matlabInstances
% MATLABINSTANCES checks the total number of instances of MATLAB running
%   n = matlabInstances
%
%   NOTE: This function works on Windows OS only. 
%
%   Input(s)
%       [NONE]
%
%   Output(s)
%       n - 1x1 array specifying the total number of MATLAB instances
%           running (including the current instance).
%
%   M. Kutzer, 14Apr2026, USNA

%% Check input(s)
narginchk(0,0);

%% Query the system for matlab.exe processes
% Instances across all users 
%[status, cmdout] = system('tasklist /FI "IMAGENAME eq MATLAB.exe" /NH');

% Get the current Windows username
currentUser = getenv('USERNAME');

% Construct the tasklist command with two filters:
%  - IMAGENAME eq MATLAB.exe
%  - USERNAME eq [your_username]
cmd = sprintf('tasklist /FI "IMAGENAME eq MATLAB.exe" /FI "USERNAME eq %s" /NH', currentUser);

% Execute the command
[~, cmdout] = system(cmd);

%% Count how many times "MATLAB.exe" appears in the output
% Note: The current instance will always be counted, so look for > 1
n = numel(strfind(cmdout, 'MATLAB.exe'));