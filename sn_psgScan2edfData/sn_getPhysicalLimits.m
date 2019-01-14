function [ signal, signalheader ] = sn_getPhysicalLimits(signal, signalheader, varargin )
% adjusts signalheader for physical limits, and possibly changes prefixes
%-----------------------------------------------------------
% Dagmar Krefting, 17.07.2015, dagmar.krefting@htw-berlin.de
% Version: 1.0
%-----------------------------------------------------------
%
%USAGE: [ signal,signalheader ] = sn_getPhysicalLimits(signal, signalheader, varargin )
%
% INPUT:
% signal            timeseries signal
% signalheader      blockEDF signalheader struct

%OPTIONAL INPUT:
% varargin1         Description
%                   Default: 
% debug             Verbose output
%                   Default: 0
%
% OUTPUT:
% signalheader      blockEDF signalheader struct
% out2              Description
%                   More description
%
%MODIFICATION LIST:
% DK (yyyymmdd): 
% (1) modification1 description
% (2) modification1 description

%------------------------------------------------------------

%% Defaults
varargin1 = 'default';
debug = false;

% debug
if debug
    disp('Starting myFunction')
end

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

%% Start function

        %get physical min and max
        phmin = min(signal);
        phmax = max(signal);
        
        %round them to a reasonable number
        %convert to number between zero and 10, and then round up or down,
        %and then convert back
        if (phmin ~= 0)
        phmin = sign(phmin)*ceil(abs(phmin)/10^floor(log10(abs(phmin))))*10^floor(log10(abs(phmin)));
        end
        if (phmax ~= 0)
        %phmax = ceil(phmax/10^floor(log10(phmax)))*10^floor(log10(phmax));
        phmax = sign(phmax)*ceil(abs(phmax)/10^floor(log10(abs(phmax))))*10^floor(log10(abs(phmax)));
        end
        %if phmin negativ, take the higher value as limit to get symmetric
        %digital limits
        if debug
            phmin
            phmax
        end
        if (phmin < 0 && phmax > 0)
            phlimit = max(abs(phmin),phmax);
            phmin = -1*phlimit;
            phmax = phlimit;       
        end
        %use mV instead of V if physmin/max are small
        if (phmax <= 1 && phmin >= -1)
        if (strcmp(signalheader.physical_dimension,'V'))
                signal = signal*1000;
                signalheader.physical_dimension = 'mV';
                signalheader.physical_min = phmin*1000;
                signalheader.physical_max = phmax*1000;
        elseif (strcmp(signalheader.physical_dimension,'mV'))
                signal = signal*1000;
                signalheader.physical_dimension = 'uV';
                signalheader.physical_min = phmin*1000;
                signalheader.physical_max = phmax*1000;
        end
        else
            signalheader.physical_min = phmin;
            signalheader.physical_max = phmax;
        end
