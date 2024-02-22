function closeMatlabEditor(closeUnsaved)
% CLOSEMATLABEDITOR closes all open documents in the MATLAB editor
%   closeMatlabEditor()
%   closeMatlabEditor(closeUnsaved)
%
%   Input(s)
%       closeUnsaved - binary value to force close unsaved work. For a
%                      value of 'true', unsaved work is closed. For a value
%                      of 'false' [DEFAULT], a user prompt will appear to
%                      save work. 
%
%   Output(s)
%
% References:
%   [1] Luis Mendo, "How to close one or all currently open Matlab (*.m) 
%       files from Matlab command prompt?" May 23, 2017.
%       https://stackoverflow.com/questions/28119360/how-to-close-one-or-all-currently-open-matlab-m-files-from-matlab-command-pr
%
%   M. Kutzer, 18Jan2024, USNA

% Updates
%   22Feb2024 - Replaced method of closing editor

%% Set defaults
narginchk(0,1);
if nargin < 1
    closeUnsaved = false; % Do not close unsaved documents
end

%% Close all open documents in the editor
% Get the main editor service
edtSvc  = com.mathworks.mlservices.MLEditorServices;

if closeUnsaved
    % Close all editor windows without saving
    edtSvc.getEditorApplication.closeNoPrompt;
else
    % Close all editor windows, prompting to save if necessary
    edtSvc.getEditorApplication.close;
end

%% Close all open documents in the editor (OLD METHOD)
%{
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
%}