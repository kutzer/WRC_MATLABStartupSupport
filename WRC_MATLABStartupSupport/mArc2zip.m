function mArc2zip(fpath,fname,npath)
% MARC2ZIP
%   mArc2zip(fpath,fname,npath)
%
%   Input(s)
%       fpath - filepath
%       fname - filename
%       npath - new filepath
%
%   M. Kutzer, 18Jan2024, USNA

%% Check input(s)
narginchk(3,3)

[~,bname,ext] = fileparts(fname);
if isempty(ext)
    fname = sprintf('%s.mArc',fname);
else
    switch lower(ext)
        case '.marc'
            % Zip file as expected
        otherwise
            warning('Expected *.zip filename.');
    end
end

%% Check if file exists
if ~isfile( fullfile(fpath,fname) )
    warning('Specified file does not exist.');
    return
end

%% Rename file
movefile(...
    fullfile(fpath,fname),...
    fullfile(npath,[bname,'.zip']));