function fnames = cleanUnzip(zipName)
% CLEANUNZIP unzips a specified *.zip file and all *.zip files contained
% within, then deletes the specified *.zip files.
%
%   cleanUnzip(zipName)
%
%   Input(s)
%       zipName - character array specifying full zip file path
%
%   Output(s)
%       
%
%   M. Kutzer, 13Feb2024, USNA

debug = false;

%% Check input(s)
narginchk(1,1);

if ~isfile(zipName)
    error('Specified file does not exist: %s',zipName);
end

%% Unzip file
[pname,bname,~] = fileparts(zipName);
unzipPath = fullfile(pname,bname);
unzipBase = unzipPath;

% Make sure folder name is unique
i = 0;
while true
    if ~isfolder(unzipPath)
        break
    end

    i = i+1;
    unzipPath = sprintf('%s (%d)',unzipBase,i);
end

% Unzip file to specified destination
fnames = unzip( zipName, unzipPath );

%% Delete zip file
delete(zipName);

%% Search filenames for embedded zip files
tf = endsWith(fnames,'.zip');

% Check if no embedded zip files exist
if ~any(tf)
    return
end

% Isolate embedded zip files
fnames = fnames(tf);

% Debug
if debug
    fprintf('%s - %d zip files\n',bname,numel(fnames));
end

%% Unzip embedded zip files
for i = 1:numel(fnames)
    cleanUnzip(fnames{i});
end
