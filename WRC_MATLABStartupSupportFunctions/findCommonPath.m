function pname = findCommonPath(fnames)
% FINDCOMMONPATH finds the common path shared by a series of file or
% pathnames.
%
%   pname = findCommonPath(fnames)
%
%   Input(s)
%       fnames - cell array containing full file or path names
%
%   Output(s)
%       pname - shared path name (empty if there is no shared path)
%
%   M. Kutzer, 30Jan2024, USNA

%% Check input(s)
narginchk(1,1);

if ~iscell(fnames)
    error('File or path names must be specified in a cell array.');
end

%% Check for a single file
if numel(fnames) == 1
    if isfolder(fnames{1})
        pname = fnames{1};
    else
        [pname,~,~] = fileparts(fnames{1});
    end
    return
end

%% Find common path
fparts = {};
nparts = [];
for i = 1:numel(fnames)
    fparts{i} = regexp(fnames{i},filesep,'split');
    nparts(i) = numel(fparts{i});
end

if isempty(nparts)
    % No common path found
    pname = [];
    return
end
npartsMin = min(nparts);

tf = true(1,npartsMin);
for i = 1:numel(fparts)
    for j = i:numel(fparts)
        tf = tf & matches(fparts{i}(1:npartsMin),fparts{j}(1:npartsMin));
    end
end

cparts = fparts{1}(tf);
pname = strjoin(cparts,filesep);
