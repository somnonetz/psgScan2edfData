function [ header ] = sn_modifyHeader( varargin )
% Modifies header for additional information and EDF+ conformance
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [events,extrema] = sn_matScan2matData(varargin)
%
%   inputs:
%     header:
%       type: matlab-struct
%       inputBinding:
%         prefix: header
%       doc: "A structure containing variables for each header entry"
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
%     dobformat:
%       type: string?
%       inputBinding:
%         prefix: dobformat
%       doc: "format of dob, combination of dd mm(m) yyyy and separators,
%                   default: dd.mm.yyyy"
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
%     debug:  
%       type: int?
%       inputBinding:
%         prefix: debug
%       doc: "if set to 1 debug information is provided. Default 0"
%   outputs:
%     header:
%       type: matlab-struct
%       doc: "A structure containing variables for each header entry"
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
myinput.header = NaN;

%% Optional input defaults
% additional header information
myinput.subjectid ='';
myinput.gender = '';
myinput.dob = '';
myinput.dobformat = 'dd.mm.yyyy';
myinput.localrecordid = '';
myinput.institution = '';
myinput.device = '';
% debug
myinput.debug = 0;

% softwareinfo
myinput.softwareinfo = 'Created with sn_matScan2matData V1.1';

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
dobDT = [];
softwareinfo = 'Created with sn_modifyHeader V1.0';

% debug
if (myinput.debug)
    disp('Starting myFunction')
end

%% Start function
if (myinput.debug)
    disp('Welcome to sn_modifyHeader')
end

%% get startdate of recording
dateComponents = strsplit(myinput.header.recording_startdate,'.');
rday = dateComponents{1};
rmonth = dateComponents{2};
ryear = dateComponents{3};
%according to EDF clippling date is 1985
if str2num(ryear) > 85
    ryear = [ '19' ryear];
else
    ryear = [ '20' ryear];
end

ryear
%datetime rather than datenum for caldiff, works not for older versions
if strcmp(version('-release'),'2015a')
    startdateDT = datetime(str2num(ryear),str2num(rmonth),str2num(rday));
    startdateString = upper(datestr(startdateDT));
else
    startdateDT = [str2num(ryear),str2num(rmonth),str2num(rday),0,0,0];
    startdateString = upper(datestr(startdateDT,'dd-mmm-yyyy'));
end

if (myinput.debug)
    whos startdateString
    startdateString
    disp(['Startdate: ' startdateString])
end

%% get datenum of dob, if set
if ~isempty(myinput.dob)
    try
        if strcmp(version('-release'),'2015a')
            dobDT = datetime(myinput.dob,'InputFormat',dobformat);
        else
            dobDT = datevec(myinput.dob,'InputFormat',dobformat);
        end
    catch
        warning('dob format not correct, cannot be set');
        %set both dobnum and dob to empty.
        dobDT = [];
        myinput.dob = '';
    end
end

% analyse header

%% Analyse patientid
pidComponents = strsplit(myinput.header.patient_id,' ');

%check for possibly set components
%read in cell array
nPidComponents = length(pidComponents);

if (nPidComponents > 0 && isempty(myinput.subjectid))
    myinput.subjectid = pidComponents{1};
end
if (nPidComponents > 1 && isempty(myinput.gender))
    myinput.gender = pidComponents{2};
end
if (nPidComponents > 2 && isempty(myinput.dob))
    myinput.dob = pidComponents{3};
    if ~strcmpi(myinput.dob,'X')
        %transform to datetime dobDT, expecting standard
        try
            if strcmp(version('-release'),'2015a')
                dobDT = datetime(myinput.dob,'InputFormat','dd-MMM-yyyy');
            else
                dobDT = datevec(myinput.dob,'dd-mmm-yyyy');
            end
        catch
            warning('dob format not correct, cannot be set');
            %set both dobnum and dob to empty.
            dobDT = [];
            myinput.dob = '';
        end
    end
end

%% Analyse recordid
ridComponents = strsplit(myinput.header.local_rec_id,' ');

nRidComponents =  length(ridComponents);

%check if local_rec_id is already in EDF+ format
if (nRidComponents > 0 && strcmp(ridComponents{1},'Startdate'))
    % I assume that Startdate-String is already correctly set
    % get localrecordid
    if (nRidComponents > 2 && isempty(myinput.localrecordid))
        myinput.localrecordid = ridComponents{3};
    end
    % get institution
    if (nRidComponents > 3 && isempty(myinput.institution))
        myinput.institution = ridComponents{4};
    end
    % get device
    if (nRidComponents > 4 && isempty(myinput.device))
        myinput.device = ridComponents{5};
    end
end

%% check for fields, set to 'X' if empty

myinput

if isempty(myinput.subjectid)
    myinput.subjectid = 'X';
end

if isempty(myinput.gender)
    myinput.gender = 'X';
end

%get age from dob or set to X
if isempty(myinput.dob)
    myinput.dob = 'X';
end

if isempty(myinput.localrecordid)
    myinput.localrecordid = 'X';
end

if isempty(myinput.subjectid)
    myinput.subjectid = 'X';
end

if isempty(myinput.institution)
    myinput.institution = 'X';
end

if isempty(myinput.device)
    myinput.device = 'X';
end

%% set new headerfields

if (myinput.debug)
    disp(['Startdatestring: ' startdateString])
end

header = myinput.header;

header.patient_id = [ myinput.subjectid ' ' myinput.gender myinput.dob ' X'];
header.local_rec_id = ['Startdate ' startdateString ...
    ' ' myinput.localrecordid ...
    ' ' myinput.institution ...
    ' ' myinput.device ...
    ' ' myinput.softwareinfo
    ];

%check for entries fit into EDF-specs
maxLength = 80;

if (length(header.patient_id) > maxLength)
    header.patient_id = header.patient_id(1:maxLength);
end

if (length(header.local_rec_id) > maxLength)
    %put overhanging information to reserve_1
    header.reserve_1 = [ '...' ...
        header.local_rec_id(maxLength+1:length(header.local_rec_id))
        ];
    %clip record_id to maxLength
    header.local_rec_id = header.local_rec_id(1:maxLength);
end

%Just to be sure for very long entries, check also reserve_1
maxLength = 44;
if (length(header.reserve_1) > maxLength)
    header.reserve_1 = header.reserve_1(1:maxLength);
end


