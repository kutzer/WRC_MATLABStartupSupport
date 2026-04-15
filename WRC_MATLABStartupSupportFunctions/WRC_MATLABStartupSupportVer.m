function varargout = WRC_MATLABStartupSupportVer
% WRC_MATLABSTARTUPSUPPORTVER displays the WRC MATLAB Startup Support 
% Toolbox information.
%   WRC_MATLABSTARTUPSUPPORTVER displays the information to the command
%   prompt.
%
%   A = WRC_MATLABSTARTUPSUPPORTVER returns in A the sorted struct array of  
%   version information for the WRC MATLAB Startup Support Toolbox.
%     The definition of struct A is:
%             A.Name      : toolbox name
%             A.Version   : toolbox version number
%             A.Release   : toolbox release string
%             A.Date      : toolbox release date
%
%   M. Kutzer 19Mar2024, USNA

% Updates
%   02Feb2026 - Updated instructors
%   14Apr2026 - Added kill previews to startup 
%   14Apr2026 - Added close new instance of MATLAB if it is already open to
%               startup
%   14Apr2026 - Migrated close camera calibrator, previews, and figures to
%               finish.m
%   15Apr2026 - Updated closeCameraCalibrator

A.Name = 'WRC MATLAB Startup Support';
A.Version = '1.1.0';
A.Release = '(R2022a)';
A.Date = '15-Apr-2026';
A.URLVer = 1;

msg{1} = sprintf('MATLAB %s Version: %s %s',A.Name, A.Version, A.Release);
msg{2} = sprintf('Release Date: %s',A.Date);

n = 0;
for i = 1:numel(msg)
    n = max( [n,numel(msg{i})] );
end

fprintf('%s\n',repmat('-',1,n));
for i = 1:numel(msg)
    fprintf('%s\n',msg{i});
end
fprintf('%s\n',repmat('-',1,n));

if nargout == 1
    varargout{1} = A;
end