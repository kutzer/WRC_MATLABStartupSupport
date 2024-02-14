function varargout = consolidateFiles(source,destination)
% CONSOLIDATEFILES consolidates files contained in a given folder structure
% into a single folder.
%
%   consolidateFiles(source,destination)
%
%   fnames = consolidateFiles(source,destination)
%
%   Input(s)
%            source - character array defining path to consolidate.
%       destination - character array defining path for consolidated files.
%
%   Output(s)
%       fnames - full filenames for all consolidated files.
%
%   M. Kutzer, 14Feb2024, USNA

%% Check input(s)
narginchk(2,2);

if ~isfolder(source)
    error('Specified source path is not valid.');
end

% TODO - check if specified destination syntax is valid
i = 0;
destination0 = destination;
while isfolder(destination)
    i = i+1;
    destination = sprintf('%s (%d)',destination,i);
end

if ~matches(destination,destination0)
    fprintf('Specified destination already exists. Using:\n\t"%s"\n',destination);
end

%% Make destination directory
[tf,msg,msgID] = mkdir(destination);
if ~tf
    error([...
        'Unable to make the specified destination folder:\n',...
        '\t"%s"\n',...
        '%s\n'],destination,msg);
end

%% Find all files
[~,fTypes] = findAllFilesAndFolders(source,false);

%% Copy files to new destination
fnames = {};
flds = fields(fTypes);
for i = 1:numel(flds)
    for j = 1:numel(fTypes.(flds{i}))
        
        % Define full file for source
        fname_src = fTypes.(flds{i}){j};
        
        % Define full file for destination
        [~,bname,ext] = fileparts(fname_src);
        fname_dst = fullfile(destination,sprintf('%s%s',bname,ext));
        
        % Account for redundant filenames
        k = 0;
        while isfile(fname_dst)
            k = k+1;
            fname_dst = fullfile(destination,sprintf('%s (%d)%s',bname,k,ext));
        end
        
        % Copy file
        [tf,msg,msgID] = copyfile(fname_src, fname_dst);
        if ~tf
            fprintf([...
                'Unable to copy file:\n',...
                '\tFrom: "%s"\n',...
                '\t  To: "%s"\n',...
                '%s\n'],fname_src,fname_dst,msg);
            continue
        end
        
        % Append new file to fnames
        if nargout > 0
            fnames{end+1} = fname_dst;
        end
    end
end

%% Package output(s)
if nargout > 0
    varargout{1} = fnames;
end