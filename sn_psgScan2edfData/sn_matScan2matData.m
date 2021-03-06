function [ newheader, newsignalHeader, newsignalCell ] = sn_matScan2matData(varargin)
% creates EDF-conform matlabStruct with standardized labels
%
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [ newheader, newsignalHeader, newsignalCell ] = sn_matScan2matData(varargin)
%
%   inputs:
%     header:
%       type: matlab-struct
%       inputBinding:
%         prefix: header
%       doc: "A structure containing variables for each header entry"
%     signalHeader:
%       type: matlab-struct-array
%       inputBinding:
%         prefix: signalHeader
%       doc: "A struc-array containing edf signal headers"
%     signalCell:
%       inputBinding:
%         prefix: signalCell
%       type: matlab-cell-array
%       doc: "A cell array that contains the data for each signal"
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
%     startdate:
%       type: string?
%       inputBinding:
%         prefix: startdate
%       doc: "startdate of recording in the form dd.mm.yy"
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
%       doc: "A structure containing variables for each header entry"
%     signalHeader:
%       type: matlab-struct-array
%       doc: "A struc-array containing edf signal headers"
%     signalCell:
%       type: matlab-cell-array
%       doc: "A cell array that contains the data for each signal"
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
%   s:version: 1.2
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

%Version
version = '1.2';

%% required input
myinput.header = NaN;
myinput.signalHeader = NaN;
myinput.signalCell = NaN;

%% Optional input defaults
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

% softwareinfo
myinput.softwareinfo = ['Created with sn_matScan2matData V' version];



%% Start function
if (myinput.debug)
    disp('Welcome to sn_matScan2matData')
end

%% Start Processing

if (myinput.debug)
    myinput.header
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Analyse signalHeaders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of signals
nsignals = myinput.header.num_signals;
%array containing the channelmappings
labels = cell(nsignals,5);
%set all labels to "not processed = true"
labels(:,5) = {true};

%copy old header
newheader=myinput.header;

%copy signalheader
newsignalHeader = myinput.signalHeader;

%loop over all signals
for i=1:nsignals
    % put actual label and channelnumber
    labels{i,1} = myinput.signalHeader(i).signal_labels;
    labels{i,3} = i;
    %get standardlabel -labels(i,2) and channelnumber - labels(i,4)
    [labels{i,4},labels(i,2)]=sn_map_psgchannels('channelname',myinput.signalHeader(i).signal_labels,'mapfile',myinput.mapfile);
end

%% Check for umlauts and replace
for i = 1:length(labels)
    labels{i,1} = sn_replaceUmlauts('data',labels{i,1},'maxLength',16);
end

%debug
if (myinput.debug)
    labels
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Set new labels if no reference modification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%rewrite signal_labels
for channelnumber = 1:nsignals
newsignalHeader(channelnumber).signal_labels = labels{channelnumber,2};
end
if myinput.debug; disp([newsignalHeader(:).signal_labels]);end

% check for unknown labels and set to original values
nonstandards = find(strcmp([newsignalHeader(:).signal_labels],'unknown'));
if ~isempty(nonstandards)
    if myinput.debug; disp('unknown labels found'); end
    if myinput.debug; disp(nonstandards); end
    newsignalHeader(nonstandards).signal_labels = labels{nonstandards,1};
end

if myinput.debug; disp([newsignalHeader(:).signal_labels]);end
    
        

%clip longer signals in case of different lengths
for i = 1: nsignals
    %in case of heterogeneous signal lengths, cut longer signals
    if (length(myinput.signalCell{i})/myinput.signalHeader(i).samples_in_record > myinput.header.num_data_records)
        if (myinput.debug)
            disp('Heterogeneous signal length, clipping long signals')
        end
        myinput.signalCell{i} = ...
            myinput.signalCell{i}(1:...
            myinput.signalHeader(i).samples_in_record...
            *myinput.header.num_data_records);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2.a. Set new labels and process reference modification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(myinput.modifyreference)
    %here it's getting much more complicated, as signals are actually modified
    
    %find unreferenced recognized channels to be referenced with -1
    unreferenced_1 = find(labels{:,4} == -4);
    if ~isempty(unreferenced_1)
        disp('Unreferenced labels found, looking for reference 1...')
        reference_1 = find(labels{:,4} == -1);
        if (~isempty(reference_1) & length(reference_1) == 1)
            disp('Reference 1 found, referencing...')
            for k = 1:length(unreferenced_1)
                %define index
                l = unreferenced_1(k);
                signalCell{l} = ...
                    signalCell{l}-signalCell{reference_1(1)};
                %set new signal-label
                reflabel = [labels(l,1) '-' labels(reference_1(1),1)];
                %set standardized referenced label, if recognized
                [cn,newsignalHeader(l).signal_labels] = ...
                    sn_map_psgchannels('channelname',reflabel,'mapfile',myinput.psgchannelmapfile);
            end
        end
    end
    
    
    %find unreferenced recognized channels to be referenced with -2
    unreferenced_2 = find(labels{:,4} == -3);
    if ~isempty(unreferenced_2)
        disp('Unreferenced labels found, looking for reference 1...')
        reference_2 = find(labels{:,4} == -2);
        if (~isempty(reference_2) & length(reference_2) == 1)
            disp('Reference 2 found, referencing...')
            for k = 1:length(unreferenced_2)
                %define index
                l = unreferenced_2(k);
                signalCell{l} = ...
                    signalCell{l}-signalCell{reference_2(1)};
                %set new signal-label
                reflabel = [labels(l,1) '-' labels(reference_2(1),1)];
                %set standardized referenced label, if recognized
                [cn,newsignalHeader(l).signal_labels] = ...
                    sn_map_psgchannels('channelname',reflabel,'mapfile',myinput.psgchannelmapfile);
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Modify header for EDF+ conformance and additional information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (myinput.modifyheader)
    if(myinput.debug); disp('modify header'); end
    newheader = sn_modifyHeader('header',newheader...
        ,'subjectid', myinput.subjectid ...
        ,'gender', myinput.gender ...
        ,'dob', myinput.dob ...
        ,'localrecordid', myinput.localrecordid ...
        ,'institution', myinput.institution ...
        ,'device', myinput.device ...
        ,'startdate',myinput.startdate...
        ,'debug',myinput.debug ...
        )
end
%% Check for umlaute in header textfields
 if(myinput.debug); disp('Check for umlauts'); end
%signalHeader
for i = 1:newheader.num_signals
    newsignalHeader(i).transducer_type = sn_replaceUmlauts('data',newsignalHeader(i).transducer_type,'maxLength',80,'debug',myinput.debug);
    newsignalHeader(i).physical_dimension = sn_replaceUmlauts('data',newsignalHeader(i).physical_dimension,'maxLength',8,'debug',myinput.debug);
    newsignalHeader(i).prefiltering = sn_replaceUmlauts('data',newsignalHeader(i).prefiltering,'maxLength',80,'debug',myinput.debug);
    newsignalHeader(i).reserve_2 = sn_replaceUmlauts('data',newsignalHeader(i).reserve_2,'maxLength',32,'debug',myinput.debug);
end

%header
newheader.patient_id = sn_replaceUmlauts('data',newheader.patient_id,'maxLength',80,'debug',myinput.debug);
newheader.local_rec_id = sn_replaceUmlauts('data',newheader.local_rec_id,'maxLength',80,'debug',myinput.debug);
newheader.reserve_1 = sn_replaceUmlauts('data',newheader.reserve_1,'maxLength',44,'debug',myinput.debug);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Check for correct settings in digital_min and digital_max
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%in case of heterogeneous signal lengths, cut longer signals
for i = 1:newheader.num_signals
    % check for correct settings in digital_min and digital_max
    if (newsignalHeader(i).digital_min == newsignalHeader(i).digital_max)
        disp('Digital min and max not correctly set, setting to 16-bit resolution')
        newsignalHeader(i).digital_min = -32768;
        newsignalHeader(i).digital_max =  32767;
    end
    %harmonize samples in record datatype
    newsignalHeader(i).samples_in_record = double(newsignalHeader(i).samples_in_record);
end

% copy signals to output
newsignalCell = myinput.signalCell; 
if myinput.debug; disp([newsignalHeader(:).signal_labels]);end
if myinput.debug; disp('Byebye from sn_matScan2matData');end




