function [ status, header, signalheader, signalcell, newheader, newsignalheader, newsignalcell ] = sn_edfScan2edfData(varargin)
% creates EDF-conform EDF with standardized labels
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [ status, header, signalheader, signalcell, newheader, newsignalheader, newsignalcell ] = sn_edfScan2edfData(varargin)
%
%   inputs:
%     data:
%       type: file
%       inputBinding:
%         prefix: data
%       doc: "path to edf-file"
%     outputfilebase:
%       type: string?
%       inputBinding:
%         prefix: outputfilebase
%       doc: "outputfilebase for final output edf"
%     subjectid:
%       type: string?
%       inputBinding:
%         prefix: subjectid
%       doc: "subject identifier to allow setting in header.patient_id"
%     gender:
%       type: string?
%       inputBinding:
%         prefix: gender
%       doc: "gender of the subject: 'M'(male),'F'(female),'O'(other),'U'(unknown)
%               default: X"
%     dob:
%       type: string?
%       inputBinding:
%         prefix: dob
%       doc: "day of birth in dd-MMM-yyy, e.g. 01-JAN1999, default: X"
%     localrecordid:
%       type: string?
%       inputBinding:
%         prefix: localrecordid
%       doc: "id of the recording, default: X"
%     institution:
%       type: string?
%       inputBinding:
%         prefix: institution
%       doc: "name of the clinics the data was acquired, default: X"
%     device:
%       type: string?
%       inputBinding:
%         prefix: device
%       doc: "name of the device or of the manufacturer, default: X"
%     modifyheader:
%       type: int?
%       inputBinding:
%         prefix: modifyheader
%       doc: "If set to zero, header should not be modified,
%             otherwise modified to edf+ conformance, default: 1"
%     modifyreference:
%       type: int?
%       inputBinding:
%         prefix: modifyreference
%       doc: "If set to one, try standardized signal references,
%               such as combine F1 and A2 to EEG F1-A2, default: 0"
%     xnat:
%       type: int?
%       inputBinding:
%         prefix: xnat
%       doc: "If set to one, xnat metadata files are written, default: 0"
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
%     header:
%       type: matlab-struct
%       doc: "original edf-header"
%     signalHeader:
%       type: matlab-struct-array
%       doc: "original edf-signal header"
%     signalCell:
%       type: matlab-cell-array
%       doc: "A cell array that contains the original data for each signal"
%     newheader:
%       type: matlab-struct
%       doc: "A structure containing variables for each new header entry"
%     newsignalHeader:
%       type: matlab-struct-array
%       doc: "A struc-array containing new edf signal headers"
%     newsignalCell:
%       type: matlab-cell-array
%       doc: "A cell array that contains the new data for each signal"
%     outputfile:
%       type: file
%       doc: "The standardized edf"
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
myinput.data = NaN;

%% Optional input defaults
myinput.outputfilebase ='';
% additional header information
myinput.subjectid ='';
myinput.gender = '';
myinput.dob = '';
myinput.localrecordid = '';
myinput.institution = '';
myinput.device = '';
% default: modify header
myinput.modifyheader = 1;
% default: modify reference
myinput.modifyreference = 0;
%mapfile
myinput.mapfile='psg_channelmap.txt';
%write to xnat
myinput.xnat = 0;
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
end%reads compumedics psg files and creates structures similar to loadblockEDF




%% Start function
if (myinput.debug)
    disp('Welcome to sn_edfScan2edfData')
end

%% Set outputfilebase
if isempty(myinput.outputfilebase)
    %get fileparts from filename
    [pathstr,basename,ext] = fileparts(myinput.data);
    myinput.outputfilebase=basename;
end

%debug
if (myinput.debug)
    disp(['Outputfilebase: ' myinput.outputfilebase]);
end

%% read complete EDF-File

[header,signalheader,signalcell] = ...
    sn_edfScan2matScan('data',myinput.data,'debug',myinput.debug);

%debug
if (myinput.debug)
    header
end

%% Transform to harmonized Data, parse parameters

[ status, newheader, newsignalheader, newsignalcell] =...
    sn_matScan2edfData('header',header,'signalHeader',signalheader,...
    'signalCell',signalcell,...
    'outputfilebase',myinput.outputfilebase,...
    'subjectid',myinput.subjectid,'gender',myinput.gender,...
    'dob',myinput.dob,...
    'localrecordid',myinput.localrecordid,...
    'institution',myinput.institution,...
    'device',myinput.device,...
    'modifyheader',myinput.modifyheader,...
    'mapfile',myinput.mapfile,...
    'debug',myinput.debug);

%% finish 
status=0;
end
