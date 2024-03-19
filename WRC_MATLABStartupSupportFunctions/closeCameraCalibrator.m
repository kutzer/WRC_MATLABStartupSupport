function closeCameraCalibrator
% CLOSECAMERACALIBRATOR closes the MATLAB camera calibrator
%   closeCameraCalibrator()
%
%   Input(s)
%   
%   Output(s)
%
%   M. Kutzer, 19Mar2024, USNA

%%
% Acccess the editor Java object.
desktop = com.mathworks.mde.desk.MLDesktop.getInstance;	% desktop object

while true
    % Get the camera calibrator group
    %jEditor = desktop.getGroupContainer('Camera Calibrator').getTopLevelAncestor; 
    jEditor = desktop.getFrameContainingGroup('Camera Calibrator');
    
    % Return if no camera calibrator is found
    if isempty(jEditor)
        return
    end

    % Get the number of open documents
    %D = jEditor.getGroup.getDocumentCount;

    % Programmatically make the editor the window in front
    jEditor.requestFocus;
    
    % Programmatically send "ALT-F4" keystroke for each open document
    robot = java.awt.Robot;
    %for n = 1:D
    robot.keyPress(java.awt.event.KeyEvent.VK_ALT);     % press "ALT"
    robot.keyPress(java.awt.event.KeyEvent.VK_F4);      % press "F4"
    robot.keyRelease(java.awt.event.KeyEvent.VK_F4);    % release "F4"
    robot.keyRelease(java.awt.event.KeyEvent.VK_ALT);   % release "ALT"
    drawnow

    %{
    % Programmatically send "TAB, ENTER" or "ENTER" keystroke
    if closeUnsaved
        %robot.keyPress(java.awt.event.KeyEvent.VK_N);   % press "N"
        %robot.keyRelease(java.awt.event.KeyEvent.VK_N); % release "N"
        robot.keyPress(java.awt.event.KeyEvent.VK_TAB);     % press "TAB"
        robot.keyRelease(java.awt.event.KeyEvent.VK_TAB);   % release "TAB"
        robot.keyPress(java.awt.event.KeyEvent.VK_ENTER);   % press "ENTER"
        robot.keyRelease(java.awt.event.KeyEvent.VK_ENTER); % release "ENTER"
    else
        robot.keyPress(java.awt.event.KeyEvent.VK_ENTER);   % press "ENTER"
        robot.keyRelease(java.awt.event.KeyEvent.VK_ENTER); % release "ENTER"
        robot.keyPress(java.awt.event.KeyEvent.VK_ENTER);   % press "ENTER"
        robot.keyRelease(java.awt.event.KeyEvent.VK_ENTER); % release "ENTER"
    end
    drawnow
    %}
    %end
end