function WRC_MATLABStartupSupportUpdate
% WRC_MATLABSTARTUPSUPPORTUPDATE download and update the WRC MATLAB Startup
% Support Package. 
%
%   M. Kutzer, 31Jan2024, USNA

% Updates
%   26Feb2024 - Updated "ToolboxUpdate" to attempt multiple times to remove
%               temporary directory to account for PowerShell execution.

% TODO - Find a location for Example SCRIPTS
% TODO - update function for general operation

% Update WRC MATLAB Camera Support
ToolboxUpdate('WRC_MATLABStartupSupport');

end

function ToolboxUpdate(toolboxName)

%% Setup functions
ToolboxVer = str2func( sprintf('%sVer',toolboxName) );
installToolbox = str2func( sprintf('install%s',toolboxName) );

%% Check current version
try
    A = ToolboxVer;
catch ME
    A = [];
    fprintf('No previous version of %s detected.\n',toolboxName);
end

%% Setup temporary file directory
fprintf('Downloading the %s...',toolboxName);
tmpFolder = sprintf('%s',toolboxName);
pname = fullfile(tempdir,tmpFolder);
if isfolder(pname)
    % Remove existing directory
    [ok,msg] = rmdir(pname,'s');
end
% Create new directory
[ok,msg] = mkdir(tempdir,tmpFolder);

%% Download and unzip toolbox (GitHub)
url = sprintf('https://github.com/kutzer/%s/archive/main.zip',toolboxName);
try
    %fnames = unzip(url,pname);
    %urlwrite(url,fullfile(pname,tmpFname));
    tmpFname = sprintf('%s-master.zip',toolboxName);
    websave(fullfile(pname,tmpFname),url);
    fnames = unzip(fullfile(pname,tmpFname),pname);
    delete(fullfile(pname,tmpFname));
    
    fprintf('SUCCESS\n');
    confirm = true;
catch ME
    fprintf('FAILED\n');
    confirm = false;
    fprintf(2,'ERROR MESSAGE:\n\t%s\n',ME.message);
end

%% Check for successful download
alternativeInstallMsg = [...
    sprintf('Manually download the %s using the following link:\n',toolboxName),...
    newline,...
    sprintf('%s\n',url),...
    newline,...
    sprintf('Once the file is downloaded:\n'),...
    sprintf('\t(1) Unzip your download of the "%s"\n',toolboxName),...
    sprintf('\t(2) Change your "working directory" to the location of "install%s.m"\n',toolboxName),...
    sprintf('\t(3) Enter "install%s" (without quotes) into the command window\n',toolboxName),...
    sprintf('\t(4) Press Enter.')];
        
if ~confirm
    warning('InstallToolbox:FailedDownload','Failed to download updated version of %s.',toolboxName);
    fprintf(2,'\n%s\n',alternativeInstallMsg);
	
    msgbox(alternativeInstallMsg, sprintf('Failed to download %s',toolboxName),'warn');
    return
end

%% Find base directory
install_pos = strfind(fnames, sprintf('install%s.m',toolboxName) );
sIdx = cell2mat( install_pos );
cIdx = ~cell2mat( cellfun(@isempty,install_pos,'UniformOutput',0) );

pname_star = fnames{cIdx}(1:sIdx-1);

%% Get current directory and temporarily change path
cpath = cd;
cd(pname_star);

%% Install Toolbox
installToolbox(true);

%% Move back to current directory and remove temp file
cd(cpath);
ok = false;
iter = 0;
iterMAX = 10;
while ~ok
    % Attempt to remove temporary directory multiple times to account for
    %   background PowerShell script
    [ok,msg] = rmdir(pname,'s');
    pause(0.05);
    iter = iter+1;
    if iter > 20
        break
    end
end
if ~ok
    warning('Unable to remove temporary download folder. %s',msg);
end

%% Complete installation
fprintf('Installation complete.\n');

end
