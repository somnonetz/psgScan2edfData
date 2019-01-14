function [ channelnumberstandard, channellabelstandard ] = sn_map_psgchannels(varargin)
%maps the current channelname to standard.
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [channelnumberstandard, channellabelstandard ] = sn_map_psgchannels(varargin)
%
%   inputs:
%     channelname:
%       type: string
%       inputBinding:
%         prefix: channelname
%       doc: "label of the channel, e.g. given in signalheader.signal_labels"
%     mapfile:
%       type: file?
%       inputBinding:
%         prefix: mapfile
%       doc: "Path of file with standard labels and channels,
%             default: ./psg_channelmap.txt"
%     debug:
%       type: int?
%       inputBinding:
%         prefix: debug
%       doc: "if set to 1 debug information is provided. Default 0"
%   outputs:
%     channelnumberstandard:
%       type: int
%       doc: "Number of standard channel, if unknown: 0"
%     channellabelstandard:
%       type: string
%       doc: "Recognized labels: the standard label, Unknown labels: "unknown""
%
%   s:author:
%     - class: s:Person
%       s:identifier:  https://orcid.org/0000-0002-7238-5339
%       s:email: mailto:dagmar.krefting@htw-berlin.de
%       s:name: Dagmar Krefting
%
%   s:dateCreated: "2019-01-12"
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
myinput.channelname = NaN;

%% Optional input defaults
%mapfile
myinput.psgchannelmapfile='psg_channelmap.txt';
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


%% Defaults
channelnumberstandard=0;
channellabelstandard{1}='unknown';


% debug
if (myinput.debug)
    disp('Welcome to sn_map_psgchannels')
end

% convert channelname to upper case
myinput.channelname = upper(myinput.channelname);

% read psg_channelmap.txt
channelmaps = readtable(myinput.psgchannelmapfile,'Delimiter',':');

if (myinput.debug)
    disp(myinput.channelname)
end

% compare strings removing all blanks and whitespaces
for i =1:length(channelmaps.Label)
    if strcmp(deblank(regexprep(myinput.channelname, '\s+', '')), deblank(channelmaps.Label(i)))
        if (myinput.debug)
            disp([ strtrim(deblank(regexprep(myinput.channelname, '\s+', ''))) ' ' deblank(channelmaps.Label(i))])
        end
        channelnumberstandard=channelmaps.Channel1(i);
        channellabelstandard=strtrim(channelmaps.Labelstandard(i));
        return;
    end
end

% debug
if (myinput.debug)
    disp('Goodbye from sn_map_psgchannels')
end

