function [fnames,dateInfo] = findmArcFiles
% FINDMARCFILES finds all mArc files for a given user.
%
%   fnames = findmArcFiles
%
%   Input(s)
%       [NONE]
%
%   Output(s)
%       fnames   - cell array containing full filenames for all mArc files.
%       dateInfo - [OPTIONAL] datetime array containing the date/time 
%                  information for each mArc file found.
%
%   M. Kutzer, 13Feb2024, USNA

%% Check input(s)
narginchk(0,0);

%% Specify mArc file information
pname = tempdir;
ext = '*.mArc';

%% Find mArc files
fnames = findFiles(pname,ext);

% Anticipated filename format
% zipName = sprintf('archive_%s',datestr(now,'yy-mm-dd_hhMMss'));

% Regular expression pattern to extract numbers
pattern = '(\d{2})-(\d{2})-(\d{2})_(\d{2})(\d{2})(\d{2})';
for i = 1:numel(fnames)
    % Parse filename
    [~,fname,~] = fileparts(fnames{i});
    
    % Use regular expression to extract numbers
    tokens = regexp(fname, pattern, 'tokens');
    
    % Check for correct number of tokens
    if ~iscell(tokens) || numel(tokens{1}) ~= 6
        fprintf('Ignoring unexpected filename: "%s.mArc"\n',fname);
        continue
    end
    
    % Convert extracted values to double
    %   vals = [yy,mm,dd,hh,MM,ss]
    vals = cellfun(@(x) str2double(x), tokens{1});
    
    % Convert 2-value year to 4-value year
    % TODO - do this better!
    vals(1) = vals(1) + 2000;
    
    % Convert to date info
    dateInfo = datetime(vals);
end