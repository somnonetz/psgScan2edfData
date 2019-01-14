function [ status ] = sn_matPsgHeader2xnatPsg(header,outputfilebase,varargin)
% reads EDF headerdata and writes in xnat-compatible xml and urls for psg-scans
%
%-----------------------------------------------------------
% Dagmar Krefting, 3.12.2015, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: sn_writeEDFHeader2xnatStructure(outputfilebase, varargin)
% INPUT: 
% header          Struct containing header, created by blockEdfLoad
%outputfilebase   Name of outputfilebase
%
%OPTIONAL INPUT:
%'xsiType' snet01-Datatype:PSGScan or psgEDFData  
%           Default: PSGScan
%'fappendix'    appendix to the outputfilebase for better recognition
%               Default: 'none'
%'sappendix'    appendix before the file extension
%               Default: 'h'
% debug     verbose output
%            Default: false
%
% CALLS:
% sn_string2url
% 
% 
%MODIFICATION LIST:
% 
%------------------------------------------------------------


%%  Defaults
xsiType='PSGScanData';
fappendix='';
sappendix='h';
debug = false;

%% Get optional input

%size of varargin
m = size(varargin,2);

%if varargin present, check for keywords and get parameter
if m > 0
    %disp(varargin);
    for i = 1:2:m-1
        %outputfile
        if strcmp(varargin{i},'datatype')
            xsiType = varargin{i+1};
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

%% Start function
%get scanner type
lrid = strsplit(header.local_rec_id);
if debug
disp('')
end

if (size(lrid) >= 5)
    scanner = lrid{5};
else 
    scanner = 'unknown';
end

if debug
disp(['PSG Model: ' scanner]);
end
%get duration in minutes
duration = round(header.num_data_records*header.data_record_duration/60);

%open outputfiles for writing
outputxml = [outputfilebase '_ ' sappendix '.xml'];
fout = fopen(outputxml,'w');

%write xml-Header
fprintf(fout,'<snet01:%s ID="" xmlns:xnat="http://nrg.wustl.edu/xnat" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:snet01="htw-berlin.de/projekte/snet01" xmlns:xdat="http://nrg.wustl.edu/xdat" xmlns:xs="http://www.w3.org/2001/XMLSchema">\n',xsiType);
fprintf(fout,'<snet01:edfversion>%s</snet01:edfversion>\n',header.edf_ver);
fprintf(fout,'<snet01:patientid>%s</snet01:patientid>\n',header.patient_id);
fprintf(fout,'<snet01:localrecordid>%s</snet01:localrecordid>\n',header.local_rec_id);
fprintf(fout,'<snet01:recordingstartdate>%s</snet01:recordingstartdate>\n',header.recording_startdate);
fprintf(fout,'<snet01:recordingstarttime>%s</snet01:recordingstarttime>\n',header.recording_starttime);
fprintf(fout,'<snet01:numberofheaderbytes>%d</snet01:numberofheaderbytes>\n',header.num_header_bytes);
fprintf(fout,'<snet01:reservedheaderfield>%s</snet01:reservedheaderfield>\n',header.reserve_1);
fprintf(fout,'<snet01:numberofdatarecords>%d</snet01:numberofdatarecords>\n',header.num_data_records);
fprintf(fout,'<snet01:durationofdatarecordseconds>%d</snet01:durationofdatarecordseconds>\n',header.data_record_duration);
fprintf(fout,'<snet01:numberofsignalsindatarecord>%d</snet01:numberofsamplesindatarecord>\n',header.num_signals);
fprintf(fout,'<xnat:scanner>%s</xnat:psgdevice>\n',scanner);
fprintf(fout,'<xnat:frames>%d</xnat:durationofrecordhours>\n',duration);
fprintf(fout,'</snet01:PSGScan>');

%close outputfile
fclose(fout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%make all strings url-compatible
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

edf_ver_url = sn_string2url(header.edf_ver);
patient_id_url = sn_string2url(header.patient_id);
local_rec_id_url = sn_string2url(header.local_rec_id);
recording_startdate_url = sn_string2url(header.recording_startdate);
recording_starttime_url = sn_string2url(header.recording_starttime);
reserve_1_url = sn_string2url(header.reserve_1);

%write url
%open outputfiles for writing
outputurl = [outputfilebase '_' sappendix '.url'];
foutu = fopen(outputurl,'w');

%write url
fprintf(foutu,'&snet01:%s/edfversion=%s',xsiType,edf_ver_url);
fprintf(foutu,'&snet01:%s/patientid=%s',xsiType,patient_id_url);
fprintf(foutu,'&snet01:%s/localrecordid=%s',xsiType,local_rec_id_url);
fprintf(foutu,'&snet01:%s/recordingstartdate=%s',xsiType,recording_startdate_url);
fprintf(foutu,'&snet01:%s/recordingstarttime=%s',xsiType,recording_starttime_url);
fprintf(foutu,'&snet01:%s/numberofheaderbytes=%i',xsiType,header.num_header_bytes);
fprintf(foutu,'&snet01:%s/reservedheaderfield=%s',xsiType,reserve_1_url);
fprintf(foutu,'&snet01:%s/numberofdatarecords=%i',xsiType,header.num_data_records);
fprintf(foutu,'&snet01:%s/durationofdatarecordseconds=%d',xsiType,header.data_record_duration);
fprintf(foutu,'&snet01:%s/numberofsignalsindatarecord=%d',xsiType,header.num_signals);
fprintf(foutu,'&snet01:%s/psgdevice=%s',xsiType,scanner);
fprintf(foutu,'&snet01:%s/durationofrecordhours=%f',xsiType,duration);

%close outputfile
fclose(foutu);

status=0;


end