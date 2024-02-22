function [allUsers,currentUser] = getSignedInUsers
% GETSIGNEDINUSERS finds all users logged in to Windows machine.
%
%   [allUsers,currentUser] = getSignedInUsers
%
%   Input(s)
%       [NONE]
%
%   Output(s)
%          allUsers - Nx1 character array containing all users currently
%                     signed in to the local Windows machine.
%       currentUser - character array defining current user. This should
%                     match the output of getenv('USERNAME').
%
%   M. Kutzer, 22Feb2024, USNA

%% Check input(s)
narginchk(0,0);

%% Get function path
ffname = which( [mfilename,'.m'] );
[pname,~,~] = fileparts(ffname);

%% Run PowerShell script
fname = 'listSignedInUsers.ps1';
psName = fullfile(pname,fname);
[status, cmdout] = system(...
    sprintf('powershell.exe -File "%s"',psName) );

% TODO - use status

%% Parse command output
allUsers = strsplit(cmdout, '\n').';

% Find and remove empty cells
tfEmpty = cellfun(@isempty, allUsers);
allUsers(tfEmpty) = [];

%% Find current user
tfUser = contains(allUsers,'>');
if nnz(tfUser) == 1
    % Remove '>' symbol from allUsers
    allUsers{tfUser} = allUsers{tfUser}(2:end);
    % Define current user
    currentUser = allUsers{tfUser};
else
    warning([...
        'Unexpected PowerShell script output:\n\n',...
        '"%s"\n\n',...
        ' --> %d current users found.'],cmdout,nnz(tfUser));
end

