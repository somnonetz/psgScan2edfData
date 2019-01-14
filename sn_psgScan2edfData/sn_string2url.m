function [ urlstring ] = sn_string2url( arbitrarystring,varargin )
% exchanges reserved url-symbols to referring escape characters
%-----------------------------------------------------------
% Dagmar Krefting, 15.04.2015, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: [ urlstring ] = sn_string2url( arbitrarystring )
%
% INPUT:
% arbitrarystring   Strings that may contain blanks and some symbols

%OPTIONAL INPUT:
% debug             Verbose output
%                   Default: false
%
% OUTPUT:
% urlstring         string where symbols are replaced by url-compatible
%                   coding
%
% CALLS:
% none
%
%
% MODIFICATION LIST:
% DK (yyyymmdd):
% (1) modification1 description
% (2) modification1 description

%------------------------------------------------------------

%% Defaults
debug = false;


%% Get optional input

%size of varargin
m = size(varargin,2);

%if varargin present, check for keywords and get parameter
if m > 0
    %disp(varargin);
    for i = 1:2:m-1
        %outputfile
        if strcmp(varargin{i},'varargin1')
            varargin1 = varargin{i+1};
        elseif strcmp(varargin{i},'debug')
            debug = varargin{i+1};
        end
    end
end

% debug
if debug
    disp('Starting sn_string2url')
end

if debug
    disp(arbitrarystring)
end

if isempty(arbitrarystring)
    %use blank
    urlstring='%20';
else
    %replace % to %25
    urlstring = strrep(arbitrarystring,'%','%25');
    %replace blank to %20
    urlstring = strrep(urlstring,' ','%20');
    %replace ! to %21
    urlstring = strrep(urlstring,'!','%21');
    %replace # to %23
    urlstring = strrep(urlstring,'#','%23');
    %replace & to &26
    urlstring = strrep(urlstring,'&','%26');
    %replace ' to %27 (encoded in matlab with two single quotes)
    urlstring = strrep(urlstring,'''','%27');
    %replace ( to %28
    urlstring = strrep(urlstring,'(','%28');
    %replace ) to %29
    urlstring = strrep(urlstring,')','%29');
    %replace * to %2A
    urlstring = strrep(urlstring,'*','%2A');
    %replace + to %2B
    urlstring = strrep(urlstring,'+','%2B');
    %replace , to %2C
    urlstring = strrep(urlstring,',','%2C');
    %replace / to %2F
    urlstring = strrep(urlstring,'/','%2F');
    %replace : to %3A
    urlstring = strrep(urlstring,':','%3A');
    %replace ; to %3B
    urlstring = strrep(urlstring,';','%3B');
    %replace = to %3D
    urlstring = strrep(urlstring,'=','%3D');
    %replace ? to %3F
    urlstring = strrep(urlstring,'?','%3F');
    %replace @ to %40
    urlstring = strrep(urlstring,'@','%40');
    %replace [ to %5B
    urlstring = strrep(urlstring,'[','%5B');
    %replace ] to %5D
    urlstring = strrep(urlstring,']','%5D');
end
end

