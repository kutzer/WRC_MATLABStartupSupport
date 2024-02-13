function [fnames,pname] = findFiles(pname,ext)
% FINDFILES finds all files in a designated path with a specified 
% extension.
%
%   fnames = findFiles(pname,ext)
%
%   [fnames,pname] = findFiles(pname,ext)
%
%   Input(s)
%       pname - character array defining folder of interest
%       ext   - character array  defining file extension to find (e.g. 
%               '*.bmp')
%
%   Output(s)
%       fnames - cell array of found file names. If a single output is
%                specified, fnames contains full filenames. If two outputs 
%                are specified, fnames contains the filename only.
%       pname  - [OPTIONAL] character array defining path containing found 
%                files.
%
%   M. Kutzer, 13Feb2024, USNA

%% Check input(s)
narginchk(2,2);

if ~isfolder(pname)
    error('Specified folder path is invalid.');
end

if numel(ext) < 3 || ~matches(ext(1:2),'*.')
    error('Specified file extension is invalid. Specify file extensions using ''*.[ext]''.');
end

%% Find files in specified path
d = dir( fullfile(pname,ext) );

%% Compile files
fnames = cell(numel(d),1);
for i = 1:numel(d)
    if nargout < 2
        % Return full file name
        fnames{i} = fullfile( pname, d(i).name );
    else
        % Return file name only
        fnames{i} = d(i).name;
    end
end
