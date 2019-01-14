function [ status ] = sn_matPsgSignalHeader2xnatPsg(signalheader, outputfilebase, header, varargin)
% reads EDF signalheaderdata and writes in xnat-compatible xml and urls for psg-scans
%
%-----------------------------------------------------------
% Dagmar Krefting, 7.12.2014, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: sn_matPsgSignalHeader2xnatPsg(signalheader,outputfilebase,header,varargin)
% INPUT: 
% signalheader      Struct containing signalheader, created by blockEdfLoad
% outputfilebase    Name of outputfilebase
% header            Struct containing the header infos
%
%OPTIONAL INPUT:
%'xsiType'         snet01-Datatype:PSGScan or psgEDFData  Default: PSGScan
%'fappendix'         some arbitrary additional filename appendix
%'sappendix'         some arbitrary additional appendix before the
%extension
% debug             If set, verbose output.
%                   Default: false
%
% CALLS:
%
% sn_map_psgchannels
%
%MODIFICATION LIST:
% 
%------------------------------------------------------------
%
%% Defaults
%
% Datafile
xsiType='PSGScanData';
% mapfile
psgchannelmapfile='psg_channelmap.txt';
% appendix to outfilename
fappendix='';
% appendix to signal
sappendix='s';
% debug
debug = false; 

%% Get optional input

%size of varargin
m = size(varargin,2);

%if varargin present, check for keywords and get parameter
if m > 0
    %disp(varargin);
    for i = 1:2:m-1
        %outputfile
        if strcmp(varargin{i},'xsiType')
            xsiType = varargin{i+1};
        elseif strcmp(varargin{i},'mapfile')
            psgchannelmapfile = varargin{i+1};
        elseif strcmp(varargin{i},'fappendix')
            fappendix = varargin{i+1};
        elseif strcmp(varargin{i},'sappendix')
            sappendix = varargin{i+1};
        elseif strcmp(varargin{i},'debug')
            debug = varargin{i+1};
        end
    end
end

outputfilebase = [ outputfilebase fappendix ];

if debug
disp('Welcome to sn_matPsgSignalHeader2xnatPsg')
end

%% Start function

%--------------------------------------------------------------------------
% Analyse signalheaders
%--------------------------------------------------------------------------

nsignals = length(signalheader);
%loop over all signals
for i=1:nsignals

    if (strcmp(xsiType,'PSGScanData'))
        %get standardlabel and channel
        [channelnumberstandard,labelstandard]=sn_map_psgchannels(signalheader(i).signal_labels,'mapfile',psgchannelmapfile);
        %convert cell to char
        labelstandard=labelstandard{1};
    else
        %PSGEDFData
        if (i < 20)
            %sorted channels
            labelstandard=signalheader(i).signal_labels;
            channelnumberstandard = i;
        else
            %unsorted channels
            labelstandard=signalheader(i).signal_labels;
            channelnumberstandard = 0;
        end
    end
    
    
    %open xml-file
    outputxmlsignal = [outputfilebase '_' num2str(i,'%2.2i')  '_' sappendix '.xml'];
    fouts = fopen(outputxmlsignal,'w');
    
    %-------------------------------------------------------------
    %    Currently no way found to upload concrete Record data - needs further
    %    xnat-experience
    %-------------------------------------------------------------
    %   %Analyse modality
    %    label = signalheader(i).signal_labels;
    %     if ~empty(strfind(label,'EEG')
    %         record = 'eegRecordData';
    %     elseif ~empty(strfind(label,'EOG')
    %         record = 'eegRecordData';
    %     elseif ~empty(strfind(label,'EMG')
    %         record = 'emgRecordData';
    %     elseif ~empty(strfind(label,'ECG')
    %         record = 'ecgRecordData';
    %     elseif ~empty(strfind(label,'Flow')
    %         record = 'airflowRecordData';
    %     elseif ~empty(strfind(label,'Effort')
    %         record = 'ribCageAndAbdominalMovementsRecordData';
    %     elseif ~empty(strfind(label,'Snore')
    %         record = 'snoringSoundsRecordData';
    %     elseif ~empty(strfind(label,'Sp02')
    %         record = 'oximetryRecordData';
    %     elseif ~empty(strfind(label,'Body')
    %         record = 'bodyPositionRecordData';
    %     else record = 'arbitraryRecordData';
    %     end
    %----------------------------------------------------------
    record = 'psgRecordData';
    
    %write xml-Header
    fprintf(fouts,'<snet01:%s ID="" xmlns:xnat="http://nrg.wustl.edu/xnat" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:snet01="htw-berlin.de/projekte/snet01" xmlns:xdat="http://nrg.wustl.edu/xdat" xmlns:xs="http://www.w3.org/2001/XMLSchema">\n',record);
    fprintf(fouts,'<snet01:labeldevice>%s</snet01:labeldevice>\n',signalheader(i).signal_labels);
    fprintf(fouts,'<snet01:labelstandard>%s</snet01:labelstandard>\n',labelstandard);
    fprintf(fouts,'<snet01:samplingrate>%d</snet01:samplingrate>\n',signalheader(i).samples_in_record/header.data_record_duration);
    fprintf(fouts,'<snet01:transducertype>%s</snet01:transducertype>\n',signalheader(i).transducer_type);
    fprintf(fouts,'<snet01:physicaldimension>%s</snet01:physicaldimension>\n',signalheader(i).physical_dimension);
    fprintf(fouts,'<snet01:physicalminimum>%d</snet01:physicalminimum>\n',signalheader(i).physical_min);
    fprintf(fouts,'<snet01:physicalmaximum>%d</snet01:physicalmaximum>\n',signalheader(i).physical_max);
    fprintf(fouts,'<snet01:digitalminimum>%d</snet01:digitalminimum>\n',signalheader(i).digital_min);
    fprintf(fouts,'<snet01:digitalmaximum>%d</snet01:digitalmaximum>\n',signalheader(i).digital_max);
    fprintf(fouts,'<snet01:prefiltering>%s</snet01:prefiltering>\n',signalheader(i).prefiltering);
    fprintf(fouts,'<snet01:samplesinrecord>%d</snet01:samplesinrecord>\n',signalheader(i).samples_in_record);
    fprintf(fouts,'<snet01:channelnumberdevice>%s</snet01:channelnumberdevice>\n',num2str(i));
    fprintf(fouts,'<snet01:channelnumberstandard>%s</snet01:channelnumberstandard>\n',num2str(channelnumberstandard));
    fprintf(fouts,'</snet01:%s>',record);
    
    %close outputfile
    fclose(fouts);
    
    %write urls
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % make strings url compatible
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    signal_labels_url = sn_string2url(signalheader(i).signal_labels);
    transducer_type_url = sn_string2url(signalheader(i).transducer_type);
    physical_dimension_url = sn_string2url(signalheader(i).physical_dimension);
    prefiltering_url = sn_string2url(signalheader(i).prefiltering);
    labelstandard_url = sn_string2url(labelstandard);


    %check for empty fields (not accepted by xnat, as all elements are required)
    
    if isempty(signal_labels_url)
        signal_labels_url = 'unknown';
    end
    
    if isempty(transducer_type_url)
        transducer_type_url = 'unknown';
    end
    
    if isempty(physical_dimension_url)
        signalheader(i).physical_dimension = 'unknown';
    end

    if isempty(prefiltering_url)
        signalheader(i).prefiltering = 'unknown';
    end
    
%% Currently reserve is used for channel-number  
% if isempty(reserve_2_url)
%         reserve_2_url = 'unknown';
%     end
    
    
    %write url
    %open outputfiles for writing
    outputurl = [outputfilebase '_s_' num2str(i,'%2.2i')  '_' sappendix '.url'];
    foutus = fopen(outputurl,'w');
    
    samplingrate = signalheader(i).samples_in_record/header.data_record_duration;
    
    
    %write url
    fprintf(foutus,'&snet01:%s/records/record/labeldevice=%s',xsiType,signal_labels_url);
    fprintf(foutus,'&snet01:%s/records/record/labelstandard=%s',xsiType,labelstandard_url);
    fprintf(foutus,'&snet01:%s/records/record/samplingrate=%i',xsiType,samplingrate);
    fprintf(foutus,'&snet01:%s/records/record/transducertype=%s',xsiType,transducer_type_url);
    fprintf(foutus,'&snet01:%s/records/record/physicaldimension=%s',xsiType,physical_dimension_url);
    fprintf(foutus,'&snet01:%s/records/record/physicalminimum=%f',xsiType,signalheader(i).physical_min);
    fprintf(foutus,'&snet01:%s/records/record/physicalmaximum=%f',xsiType,signalheader(i).physical_max);
    fprintf(foutus,'&snet01:%s/records/record/digitalminimum=%i',xsiType,signalheader(i).digital_min);
    fprintf(foutus,'&snet01:%s/records/record/digitalmaximum=%i',xsiType,signalheader(i).digital_max);
    fprintf(foutus,'&snet01:%s/records/record/prefiltering=%s',xsiType,prefiltering_url);
    fprintf(foutus,'&snet01:%s/records/record/samplesinrecord=%i',xsiType,signalheader(i).samples_in_record);
    fprintf(foutus,'&snet01:%s/records/record/channelnumberdevice=%s',xsiType,num2str(i));
    fprintf(foutus,'&snet01:%s/records/record/channelnumberstandard=%s',xsiType,num2str(channelnumberstandard));
    
    %close outputfile
    fclose(foutus);
    
end


status=0;
%disp('Goodbye from sn_writeEDFHeader2xnatStructure')
end