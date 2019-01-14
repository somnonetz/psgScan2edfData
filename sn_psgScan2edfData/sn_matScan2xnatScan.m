function [ status ] = sn_matScan2xnatScan(header,signalheader,outputfilebase, varargin)
% reads EDF signalheaderdata and writes in xnat-compatible xml and urls for psg-scans
%
%-----------------------------------------------------------
% Dagmar Krefting, 7.12.2014, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: sn_writeEDFHeader2xnatStructure(outputfilebase, varargin)
% INPUT: 
% header            Struct containing the header infos
% signalheader      Struct containing signalheader, created by blockEdfLoad
% outputfilebase    Name of outputfilebase
%
%OPTIONAL INPUT:
% fappendix         some arbitrary additional filename appendix
% debug             If set, verbose output.
%                   Default: false
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
        if strcmp(varargin{i},'mapfile')
            psgchannelmapfile = varargin{i+1};
        elseif strcmp(varargin{i},'fappendix')
            fappendix = varargin{i+1};
        elseif strcmp(varargin{i},'debug')
            debug = varargin{i+1};
        end
    end
end

%% Start function
if debug
    disp('Welcome to sn_matScan2xnatScan')
end

%write headerinfos
[status] = ...
    sn_matPsgHeader2xnatPsg(header,outputfilebase,...
    'xsiType',xsiType,'fappendix',fappendix,'sappendix','hp','debug',debug);

%write signalheaderinfos
[status] = ...
    sn_matPsgSignalHeader2xnatPsg(signalheader,outputfilebase,header,...
    'xsiType',xsiType,'fappendix',fappendix,'sappendix','sp','debug',debug);


end % End of function