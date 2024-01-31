function [rFnames,commonPname] = removeCommonPath(fnames,commonPname)
% REMOVECOMMONPATH removes the common portion of a path from a set of full
% file names.
%   
%   rFnames = removeCommonPath(fnames)
%
%   rFnames = removeCommonPath(fnames,commonPname)
%
%   Input(s)
%            fnames - cell array containing full file or path names
%       commonPname - shared path name
%
%   Output(s)
%       rFnames - cell array containing file names with common path
%                 removed. Note that folder names and files that do not
%                 share a common path will be removed.
%
%   See also findCommonPath
%
%   M. Kutzer, 31Jan2024, USNA

%% Check input(s)
narginchk(1,2);

if nargin < 2
    commonPname = findCommonPath(fnames);

    if isempty(commonPname)
        warning('No common path found for specified files.');
        rFnames = [];
        return
    end
end

% TODO - check input(s)

%% Remove common path
cParts = regexp(commonPname,filesep,'split');
n = numel(cParts);

rFnames = {};
for i = 1:numel(fnames)
    fname = fnames{i};

    fParts = regexp(fname,filesep,'split');

    if numel(fParts) > n
        tf = matches(fParts(1:n),cParts);
        if nnz(tf) > 0
            cParts = fParts(~tf);
            rFnames{i+1} = strjoin(cParts,filesep);
        else
            % File does not share a common path
            warning([...
                'The following file does not share the common path:\n' ...
                '\t\t  File Name: %s\n',...
                '\t\tCommon Path: %s'],fname,commonPname);
        end
    else
        % File name is too short
        warning([...
            'The following file does not share the common path:\n' ...
            '\t\t  File Name: %s\n',...
            '\t\tCommon Path: %s'],fname,commonPname);
    end
end