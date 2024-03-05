function userInfo = getUserInfo
% GETUSERINFO finds information about the current user on a Windows
% machine.
%
%   userInfo = getUserInfo
%
%   Input(s)
%       [NONE]
%
%   Output(s)
%       userInfo - structured array containing fields describing user
%                  information returned by $env:USERNAME in PowerShell
%           userInfo(i).Username    - character array containing username
%           userInfo(i).SessionName - 
%           userInfo(i).ID          -
%           userInfo(i).State       -
%           userInfo(i).IdleTime    -
%           userInfo(i).LogonTime   - datetime value for last login time
%
%   M. Kutzer, 22Feb2024, USNA

%% Check input(s)
narginchk(0,0);

%% Get function path
ffname = which( [mfilename,'.m'] );
[pname,~,~] = fileparts(ffname);

%% Run PowerShell script
fname = 'getUserInfo.ps1';
psName = fullfile(pname,fname);
[status, cmdout] = system(...
    sprintf('powershell.exe -File "%s"',psName) );

% TODO - use status

%% Parse command output
% Split lines
cStr = strsplit(cmdout, '\n').';

% Find and remove empty cells
tfEmpty = cellfun(@isempty, cStr);
cStr(tfEmpty) = [];

% Split using white spaces (2 or more)
cStr = regexp(cStr, '\s\s+', 'split');

% Remove excess white spaces
cStr = strtrim(cStr);

% Remove white spaces from header
cStr{1} = regexprep(cStr{1}, '\s+', '');

% Define field names
flds = {'Username','SessionName','ID','State','IdleTime','LogonTime'};
for i = 1:numel(flds)
    % Match headers to specified fields
    tfFld = matches(lower(cStr{1}),lower(flds{i}));
    
    % Output unexpected response information
    if nnz(tfFld) > 1
        mtch = cStr{1}(tfFld);
        for k = 1:numel(mtch)
            fprintf('Unexpected field name: %s\n',mtch{k});
        end
        continue
    elseif nnz(tfFld) == 0
        fprintf('"%s" was not found in PowerShell response.\n',flds{i});
        continue
    end
    
    % Package structured array
    for j = 2:size(cStr,1)
        userInfo(j-1).(flds{i}) = cStr{j}{tfFld};
        
        % Account for special case information
        switch flds{i}
            case 'Username'
                % Remove ">" from active username
                if contains(userInfo(j-1).(flds{i}),'>')
                    userInfo(j-1).(flds{i}) = userInfo(j-1).(flds{i})(2:end);
                end
            case 'LogonTime'
                infmt = 'M/d/yyyy h:mm a';
                % Convert to datetime
                userInfo(j-1).(flds{i}) = datetime(...
                    userInfo(j-1).(flds{i}),'InputFormat',infmt);
        end
    end
    
end
