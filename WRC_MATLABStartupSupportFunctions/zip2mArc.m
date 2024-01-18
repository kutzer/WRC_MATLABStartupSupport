function zip2mArc(fpath,fname)
% ZIP2MARC
%   zip2mArc(fpath,fname)
%
%   Input(s)
%       fpath - filepath
%       fname - filename
%
%   M. Kutzer, 18Jan2024, USNA

%% Check input(s)
narginchk(2,2);

[~,bname,ext] = fileparts(fname);
if isempty(ext)
    fname = sprintf('%s.zip',fname);
else
    switch lower(ext)
        case '.zip'
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
    fullfile(fpath,[bname,'.mArc']));