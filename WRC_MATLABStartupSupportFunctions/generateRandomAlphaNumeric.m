function rStr = generateRandomAlphaNumeric(dim)
% GENERATERANDOMALPHANUMERIC generates a random alpha numeric character 
% array of a designated size.
%
%   rStr = generateRandomAlphaNumeric(dim)
%
%   Input(s)
%       dim - number of characters to randomly generate
%
%   Output(s)
%       rStr - 1xdim character array of alpha numeric characters 
%
% Reference(s)
%   [1] https://stackoverflow.com/questions/8918051/how-can-i-generate-a-random-string-in-matlab
%
%   M. Kutzer, 14Feb2024, USNA

%% Check input(s)
narginchk(1,1);

if numel(dim) ~= 1 || dim ~= floor(dim) || dim < 1
    error('Number of characters must be an integer greater than 0.');
end

%% Generate random character array
% Define characters to select from
%s = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
s = 'abcdefghijklmnopqrstuvwxyz0123456789';
n = numel(s); 

% Generate random string
rStr = s( round( rand(1,dim)*n ) );