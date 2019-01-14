function [ asciistring ] = sn_replaceUmlauts(isostring,varargin)
%-----------------------------------------------------------
% Dagmar Krefting, 13.07.2015, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: [ asciistring ] = sn_replaceUmlauts(isostring,varargin)
%
% INPUT:
% isostring       String with possible iso-latin characters

%OPTIONAL INPUT:
% maxLength         MaximumLength of asciistring
%                   Default: 0 (= infinity)
% umlautList        Cellarray.  Column1: decimal values of iso-latin chars
%                               Column2: double character replacements
%                   Default: built-in German Umlaute
% debug             Verbose output
%                   Default: 0
%
% OUTPUT:
% asciistring       String with 7-bit ascii only
%                   More description
% out2              Description
%                   More description
%
%MODIFICATION LIST:
% DK (yyyymmdd):
% (1) modification1 description
% (2) modification1 description

%------------------------------------------------------------

%% Defaults
maxLength = 0;
debug = 0;
%list of German umlauts and their ascii-equivalent
umlautList =   {228,'ae';246,'oe';252,'ue'
                ;196,'Ae';214,'Oe';220,'Ue'
                ;223,'ss';176,'gC'
                };

% debug
if debug
    disp('Starting sn_replaceUmlauts')
end

%% Get optional input

%size of varargin
m = size(varargin,2);

%if varargin present, check for keywords and get parameter
if m > 0
    %disp(varargin);
    for i = 1:2:m-1
        %outputfile
        if strcmp(varargin{i},'maxLength')
            maxLength = varargin{i+1};
        elseif strcmp(varargin{i},'umlautList')
            umlautList = varargin{i+1};
        elseif strcmp(varargin{i},'debug')
            debug = varargin{i+1};
        end
    end
end

%give numbers as array
umlaut_idx = [umlautList{:,1}];

% get numeric values of character-encoding
isoDouble = double(isostring);
%find iso-latin chars
umlaute = find(isoDouble > 127);
%put current string to output
asciistring = isostring;
if ~isempty(umlaute)
    % debug
    if debug
        disp([ 'Found Umlaut in :' isostring])
    end
    for k = 1:length(umlaute)
        %first insert a blank
        asciistring = [isostring(1:umlaute(k)) ' ' isostring(umlaute(k)+1:end)];
        %now replace umlaut with two asciis
        umlautlist_idx = find(umlaut_idx == isoDouble(umlaute(k)));
        if ~isempty(umlautlist_idx)
            asciistring(umlaute(k):umlaute(k)+1) =...
                char(umlautList{umlautlist_idx,2});
            %else set question marks
        else
            asciistring(umlaute(k):umlaute(k)+1) = '??';
        end
    end
end
%check for maxlength
if (maxLength > 0 && length(asciistring) > maxLength )
    asciistring = asciistring(1:maxLength);
end
