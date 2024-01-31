function [rFnames,commonPname] = removeCommonPath(fnames,commonPname)
% REMOVECOMMONPATH removes the common portion of a path from a set of full
% file names.
%   
%   rFnames = removeCommonPath(fnames)
%
%   rFnames = removeCommonPath(fnames,commonPname)
%
%   [rFnames,commonPname] = removeCommonPath(___)
%
%   Input(s)
%            fnames - cell array containing full file or path names
%       commonPname - shared path name
%
%   Output(s)
%           rFnames - cell array containing file names with common path
%                     removed. Note that folder names and files that do not
%                     share a common path will be removed.
%       commonPname - cell defining common path. If no common path is
%                     found, commonPname is [].
%
%   See also findCommonPath
%
%   M. Kutzer, 31Jan2024, USNA

%% Check input(s)
narginchk(1,2);

if nargin < 2
    commonPname = findCommonPath(fnames);

    if isempty(commonPname)
        %warning('No common path found for specified files.');
        rFnames = {};
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
        if all(tf)
            nParts = fParts( (n+1):end );
            rFnames{end+1} = strjoin(nParts,filesep);
        else
            % File does not share a common path
            fprintf([...
                'The following file does not share the common path:\n' ...
                '\t  File Name: %s\n',...
                '\tCommon Path: %s\n'],fname,commonPname);

            tf
        end
    else
        % File name is too short
        warning([...
            'The following file does not share the common path:\n' ...
            '\t\t  File Name: %s\n',...
            '\t\tCommon Path: %s'],fname,commonPname);
    end
end