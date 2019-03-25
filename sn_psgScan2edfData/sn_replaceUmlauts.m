function [ asciistring ] = sn_replaceUmlauts(varargin)
% replaces known umlauts, otherwise puts ? for non-ascii-strings
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [events,extrema] = sn_replaceUmlauts(varargin)
%
%   inputs:
%     data:
%       type: string
%       inputBinding:
%         prefix: data
%       doc: "a string, that might contain non-ascii characters"
%     maxLength:
%       type: int?
%       inputBinding:
%         prefix: maxLength
%       doc: "MaximumLength of asciistring, default: 0 (= infinity)"
%     umlautList:
%       type: matlab-stingarray?
%       inputBinding:
%         prefix: umlautlist
%       doc: "Cellarray.  Column1: decimal values of iso-latin chars, Column2: double character replacements, Default: built-in German Umlaute"
%     debug:  
%       type: int?
%       inputBinding:
%         prefix: debug
%       doc: "if set to 1 debug information is provided. Default 0"
%   outputs:
%     asciistring:
%       type: string
%       doc: "String with 7-bit ascii only"
%
%   s:author:
%     - class: s:Person
%       s:identifier:  https://orcid.org/0000-0002-7238-5339
%       s:email: mailto:dagmar.krefting@htw-berlin.de
%       s:name: Dagmar Krefting
% 
%   s:dateCreated: "2015-07-13"
%   s:license: https://spdx.org/licenses/Apache-2.0 
% 
%   s:keywords: edam:topic_3063, edam:topic_2082
%     doc: 3063: medical informatics, 2082: matrix
%   s:programmingLanguage: matlab
% 
%   $namespaces:
%     s: https://schema.org/
%     edam: http://edamontology.org/
% 
%   $schemas:
%     - https://schema.org/docs/schema_org_rdfa.html
%     - http://edamontology.org/EDAM_1.18.owl
%
%------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Parse Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% required input
myinput.data = NaN;

%% Optional input defaults
myinput.maxLength = 0;
myinput.umlautList =   {228,'ae';246,'oe';252,'ue'
                ;196,'Ae';214,'Oe';220,'Ue'
                ;223,'ss';176,'gC'
                };
% debug
myinput.debug = 0;

try
    myinput = mt_parameterparser('myinputstruct',myinput,'varargins',varargin);
catch ME
    disp(ME)
    return
end

if (myinput.debug)
    myinput
end

% debug
if (myinput.debug)
    disp('Starting sn_replaceUmlauts')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse to legacy variable names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

isostring = myinput.data;
maxLength = myinput.maxLength;
umlautList = myinput.umlautList;
debug = myinput.debug;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%give numbers as array
umlaut_numbers = [umlautList{:,1}];

% get numeric values of character-encoding
isoDouble = double(isostring);
if (debug); disp(['Number of characters: ' num2str(length(isoDouble))]); end
%find iso-latin chars
umlaute = find(isoDouble > 127);
if (debug); disp(['Number of non-ascii characters: ' num2str(length(umlaute))]); end
%put current string to output
asciistring = isostring;
if ~isempty(umlaute)
    % debug
    if debug
        disp([ 'Found Umlaut in :' isostring])
    end
    %introduce counter, as umlauts are subsequently increasing the index by
    %one
    ucount = 0;
    for k = 1:length(umlaute)   
        %first insert a blank
        asciistring = [asciistring(1:umlaute(k)+ucount) ' ' asciistring(umlaute(k)+1+ucount:end)];
        %now replace umlaut with two asciis
        umlautlist_idx = find(umlaut_numbers == isoDouble(umlaute(k)));
        if ~isempty(umlautlist_idx)
            asciistring(umlaute(k)+ucount:umlaute(k)+1+ucount) =...
                char(umlautList{umlautlist_idx,2});
            %else set question marks
        else
            asciistring(umlaute(k)+ucount:umlaute(k)+1+ucount) = '??';
        end
        ucount = ucount+1;
    end
end
%check for maxlength
if (maxLength > 0 && length(asciistring) > maxLength )
    asciistring = asciistring(1:maxLength);
end
