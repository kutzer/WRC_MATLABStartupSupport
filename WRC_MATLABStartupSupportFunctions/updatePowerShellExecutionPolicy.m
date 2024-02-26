function updatePowerShellExecutionPolicy
% UPDATEPOWERSHELLEXECUTIONPOLICY updates the PowerShell execution policy
% on Windows PCs to enable "RemoteSigned" PowerShell scripts. This enables
% PowerShell scripts used for other functions within this toolbox.
%
%   Input(s)
%       [NONE]
%
%   Output(s)
%       [NONE]
%
%   NOTE: You must be running MATLAB as an administrator to run this
%   function.
%
%   See also getSignedInUsers getUserInfo
%
%   M. Kutzer, 26Feb2024, USNA

%% Check input(s)
narginchk(0,0);

%% Build PowerShell Command
% Define your PowerShell command
powershellCommand = 'Set-ExecutionPolicy RemoteSigned -Force';

% Build the full command to run PowerShell with administrative privileges
fullCommand = sprintf('powershell -Command "& {Start-Process powershell -ArgumentList ''-NoProfile -ExecutionPolicy Bypass -Command \"%s\"'' -Verb RunAs}"', powershellCommand);


%% Execute PowerShell command
[status, msg] = system(fullCommand);

%% Show status
if status == 0
    fprintf('PowerShell Execution Policy changed to "Remote Signed."\n');
else
    fprintf('Unable to change PowerShell Execution Policy.\n\n"%s"\n',msg);
end

