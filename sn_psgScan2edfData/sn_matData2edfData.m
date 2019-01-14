function [header,signalHeader,signalCell] = sn_matData2edfData(varargin)
% writes matlab struct in edf, based on blockEdfLoad
%-----------------------------------------------------------
%MODIFICATION LIST:
%------------------------------------------------------------
% cli:
%   cwlVersion: v1.0-extended
%   class: matlabfunction
%   baseCommand: [header,signalHeader,signalCell] = sn_matData2edfData(varargin)
%
%   inputs:
%     header:
%       type: matlab-struct
%       doc: "A structure containing variables for each header entry"
%     signalHeader:
%       type: matlab-struct-array
%       doc: "A struc-array containing edf signal headers"
%     signalCell:
%       type: matlab-cell-array
%       doc: "A cell array that contains the data for each signal"
%     filename:
%       type: string
%       inputBinding:
%         prefix: filename
%       doc: "name and full path of edf to write"
%     xnat:
%       type: int?
%       inputBinding:
%         prefix: xnat
%       doc: "If set to one, xnat metadata files are written, default: 0"
%     debug:  
%       type: int?
%       inputBinding:
%         prefix: debug
%       doc: "if set to 1 debug information is provided. Default 0"
%
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
%   s:isBasedOn: https://github.com/DennisDean/BlockEdfLoad
% 
%   $namespaces:
%     s: https://schema.org/
%     edam: http://edamontology.org/
% 
%   $schemas:
%     - https://schema.org/docs/schema_org_rdfa.html
%     - http://edamontology.org/EDAM_1.18.owl
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 0. Parse Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% required input
myinput.header = NaN;
myinput.signalHeader = NaN;
myinput.signalCell = NaN;

%% Optional input defaults
myinput.filename = 'edfData.edf';
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
end

%% Defaults
% Defaults for optional parameters            
epochs = [];               % Start and end epoch to return
status = 0;                % Write status

%write input to local variables
headerStruct = myinput.header;
signalHeaderStruct = myinput.signalHeader;
signalCell = myinput.signalCell;
filename = myinput.filename;


%% Start function
if (myinput.debug)
    disp('Welcome to sn_matData2edfData')
end

%% part of blockEdfWrite

% Initialize return counts
statusHeader = 0;
statusSignalHeader = 0;
statusSignalCell = 0;

%-------------------------------------------------------------- Input check
% Check that first argument is a string
if   ~ischar(filename)
    msg = ('First argument is not a string.');
    error(msg);
end
% Check that first argument is a string
if  ~isstruct(headerStruct)
    msg = ('Second argument is not a header structure.');
    error(msg);
end
% Check that first argument is a string
if  and(nargin ==3, ~isstruct(signalHeaderStruct))
    msg = ('Specify epochs = [Start_Epoch End_Epoch.');
    error(msg);
end
% Check if header, signal header and signal sizes are consistent
if nargin > 3
    ndr = headerStruct.num_data_records;
    drd = headerStruct.data_record_duration;
    for s = 1:headerStruct.num_signals;
        dl = length(signalCell{s})/signalHeaderStruct(s).samples_in_record;
        %here was ndr*drd, but the lengthSignal/samplesinRecord should give
        %ndr
        if ndr ~= dl
            msg = sprintf('Data size and headers are not consistent: %s (%.0f)\n',...
                signalHeaderStruct(s).signal_labels,s);
            %try to fix the problem with samplerates of zero
%             if (signalHeaderStruct(s).samples_in_record == 0)
%                 disp('zero SamplesInRecord detected. Trying to fix the problem...')
%                 disp(['Length of data: ' num2str(length(signalCell{s}))])
%                 disp(['Number of data records: ' num2str(headerStruct.num_data_records)])
%                 signalHeaderStruct(s).samples_in_record = ...
%                     ceil(length(signalCell{s})/headerStruct.num_data_records);
%                 disp(['Resulting SamplesInRecord: ' num2str(signalHeaderStruct(s).samples_in_record)])
%             else
                 error(msg);
%             end
        end
    end
end
%----------------------------------------------------- Process Header Block
% Create array/cells to create struct with loop
headerVariables = {...
    'edf_ver';             'patient_id';          'local_rec_id'; ...
    'recording_startdate'; 'recording_starttime'; 'num_header_bytes'; ...
    'reserve_1';           'num_data_records';    'data_record_duration';...
    'num_signals'};
headerVariableTypeCheck = ...
    {@isstr;      @isstr;       @isstr;...
     @isstr;      @isstr;       @isnumeric;...
     @isstr;      @isnumeric;   @isnumeric;...
     @isnumeric; ...
     };
headerVariablesConvertF = ... 
     {@(x)x;      @(x)x;        @(x)x;...
      @(x)x;      @(x)x;        @num2str;...
      @(x)x;      @num2str;     @num2str;...
      @num2str};
headerVariableSize = [ 8; 80; 80; 8; 8; 8; 44; 8; 8; 4];
headerVarLoc = vertcat([0],cumsum(headerVariableSize));
headerSize = sum(headerVariableSize);

% Process Header Information
%% correct for invalid starttime



% Create Header Structure
header = blanks(256);
for h = 1:length(headerVariables)
    % Get header variable 
    typeCheckF = headerVariableTypeCheck{h};
    value = getfield(headerStruct, headerVariables{h});
    
    if typeCheckF(value) == 1
        % Process header field
        conF = headerVariablesConvertF{h};
        value = conF(value);
        endLoc = min(headerVarLoc(h+1),headerVarLoc(h)+length(value));
        header(headerVarLoc(h)+1:endLoc) = ...
            value(1:min(length(value),headerVariableSize(h)));
        
        % Check header lengths
        if length(value) > headerVariableSize(h)
            % String was clipped
            errMsg = ...
            sprintf('Header structure variable (%s) was truncated',...
                headerVariables{h});
            error(errMsg);
        end
    else
        % Write error message
        errMsg = ...
            sprintf('Header structure variable (%s) is not appropriately typed',...
            headerVariables{h});
        error(errMsg);
    end
end

%------------------------------------------------------------- Write Header
% Open file for writing
% Load edf header to memory
[fid, msg] = fopen(filename, 'r+');

% Proceed if file is valid
if fid <0
    % Open for writing
    %dagi: w statt w+, damit das File neu angelegt wird
    [fid, msg] = fopen(filename, 'w');
    
    if fid < 0 
        msg = sprintf('Could not open or create file: %s',filename);
    	% file id is not valid
        error(msg);    
    end
end

% Process machine format
% [filename, permission, machineformat, encoding] = fopen(fid);

% Write header
try 
    % Check if only header is being changed
    edfSigHeaderSignals = [];
    if nargin == 2
        % Load original header
        edfHeaderSize = 256;
        [A count] = fread(fid, edfHeaderSize, 'int8');
        
        % Load signal header
        edfSignalHeaderSize = headerStruct.num_header_bytes-edfHeaderSize;
        edfSigHeaderBlock = fread(fid, edfSignalHeaderSize, 'int8');
        
        % Load signal information
        edfSignalsBlock = fread(fid, 'int16');
        
        % Move file pointer to begining of file;
        frewind(fid);
    end
    
    % Write header information in one call
    count = fwrite(fid, int8(header));
    statusHeader = count;
    if (myinput.debug)
        disp(['Wrote header bytes: ' num2str(count)])
    end
    
    % Check if original file must be rewritten 
    if nargin == 2
%         % Try moving to EOF, status = 0 is a successful change
%         status = fseek(fid, 0, 'eof');
        
        % Load original header
        status = fwrite(fid, int8(edfSigHeaderBlock), 'int8');
        status = fwrite(fid, int16(edfSignalsBlock), 'int16');
    end    
    
    
catch exception
    msg = 'File write error. Check available HD space / if file is open.';
    error(msg);
end

% End Header Write Section

%------------------------------------------------------ Write Signal Header
if nargin >= 3
    %------------------------------------------ Process Signal Header Block
    % Create arrau/cells to create struct with loop
    signalHeaderVar = {...
        'signal_labels'; 'transducer_type'; 'physical_dimension'; ...
        'physical_min'; 'physical_max'; 'digital_min'; ...
        'digital_max'; 'prefiltering'; 'samples_in_record'; ...
        'reserve_2' };
    signalVariableTypeCheck = ...
        {@isstr;      @isstr;      @isstr;...
         @isnumeric;  @isnumeric;  @isnumeric;...
         @isnumeric;  @isstr;      @isnumeric;...
         @isstr; ...
        };
    signalHeaderVariablesConvertF = ... 
        {@(x)x;       @(x)x;       @(x)x;...
         @num2str;    @num2str;    @num2str;...
         @num2str;    @(x)x;       @num2str;...
         @(x)x};
    num_signal_header_vars = length(signalHeaderVar);
    num_signals = headerStruct.num_signals;
    signalHeaderVarSize = [16; 80; 8; 8; 8; 8; 8; 80; 8; 32];
    signalBlockSize = sum(signalHeaderVarSize);
    signalHeaderBlockSize = signalBlockSize*num_signals;
    %position of the next variable (fields from all signals are written
    %before next headerfield ist written 
    signalHeaderVarLoc = vertcat([0],cumsum(signalHeaderVarSize)*num_signals);
    signalHeaderRecordSize = sum(signalHeaderVarSize);

    % Create Signal Header Struct
    signalHeader = struct(...
        'signal_labels', {},'transducer_type', {},'physical_dimension', {}, ...
        'physical_min', {},'physical_max', {},'digital_min', {},...
        'digital_max', {},'prefiltering', {},'samples_in_record', {},...
        'reserve_2', {});
    
    % Allocate signal header block
    signalHeader = blanks(signalHeaderBlockSize);
    
    % Get each signal header variable
    for s = 1:num_signals
        for v = 1:num_signal_header_vars
            % Get signalHeader variable
            typeCheckF = signalVariableTypeCheck{v};
            value = getfield(signalHeaderStruct(s), signalHeaderVar{v});
            %value
            % Check variable type
            if typeCheckF(value) == 1
                % Add signal header information to memory block
                
                % Process header field
                conF = signalHeaderVariablesConvertF{v};
                value = conF(value);
                startLoc = signalHeaderVarLoc(v)+1+signalHeaderVarSize(v)*(s-1);
                endLoc = min(startLoc+signalHeaderVarSize(v)-1,...
                    startLoc+length(value)-1);
                
                %debug
                %startLoc
                %endLoc
                %length_v = length(value)
                %shvs = signalHeaderVarSize(v)
                %value
                signalHeader(startLoc:endLoc) = ...
                    value(1:min(length(value),signalHeaderVarSize(v)));
                
                % Check header lengths
                if length(value) > signalHeaderVarSize(v)
                    % String was clipped
                    errMsg = ...
                        sprintf('Signal (%s) header structure variable (%s) was truncated',...
                        signalHeaderStruct(s).signal_labels, ...
                        signalHeaderVar{v});
                    error(errMsg);
                end 
            else
                % Write error message
                signalHeaderStruct(s).physical_min,
                errMsg = ...
                    sprintf('Signal (%s) header structure variable (%s) is not appropriately typed',...
                    signalHeaderStruct(s).signal_labels, signalHeaderVar{v});
                error(errMsg);
            end
        end
    end
    %-------------------------------------------------- Write Signal Header
    try 
        % Load signal header into memory in one load
        count = fwrite(fid, int8(signalHeader));
        statusSignalHeader = count;
        if (myinput.debug)
            disp(['Wrote Signalheader data bytes: ' num2str(count)])
        end
    catch exception
        msg = 'File load error. Check available memory.';
        error(msg);
    end
end % End Signal header write section

%------------------------------------------------------- Write Signal Block
if nargin >=4
    % Read digital values to the end of the file
    try
        % Set default error mesage
        errMsg = 'File write error. Check disk space.';
        
    	%-------------------------------------------- Process Signal Block
        % Get values to reshape block
        %%debug
        num_data_records = headerStruct.num_data_records;
        if (myinput.debug)
            disp(['num_data_records : ',num2str(num_data_records)])
        end
        getSignalSamplesF = @(x)signalHeaderStruct(x).samples_in_record;
        signalSamplesPerRecord = arrayfun(getSignalSamplesF,[1:num_signals]);
        recordWidth = sum(signalSamplesPerRecord);
        if (myinput.debug)
            disp(['recordWidth : ',num2str(recordWidth)])
        end       
        numRecords = num_data_records;
        if (myinput.debug)
            disp(['numRecords : ',num2str(numRecords)])
        end       

        % Create matrix to hold raw results
        A = zeros(recordWidth, num_data_records);
        if (myinput.debug)
            disp(['Allocated signal array (values): ' num2str(numberofelements(A))])
        end
        % Create raw signal cell array
        signalLocPerRow = horzcat([0],cumsum(signalSamplesPerRecord));
        for s = 1:num_signals
            % Get signal location
            signalRowWidth = signalSamplesPerRecord(s);
            signalRowStart = signalLocPerRow(s)+1;
            signaRowEnd = signalLocPerRow(s+1);
            
            % Get signal
            signal = signalCell{s};
            if (myinput.debug)
                disp(['Number of signal: ' num2str(s)])
                disp(['Length of signal: ' num2str(length(signal))])
            end
            % Get scaling factors
            dig_min = double(signalHeaderStruct(s).digital_min);
            dig_max = double(signalHeaderStruct(s).digital_max);
            phy_min = double(signalHeaderStruct(s).physical_min);
            phy_max = double(signalHeaderStruct(s).physical_max);
            
            % Get signal factor  
            signal = (signal-phy_min)/(phy_max-phy_min);
            signal = signal.*double(dig_max-dig_min)+dig_min; 
            
            value = (signal-dig_min)/(dig_max-dig_min);
            value = value.*double(phy_max-phy_min)+phy_min; 
            
            % Convert physical signal to digital signal
            signal = reshape(signal, signalSamplesPerRecord(s), ...
                num_data_records ...
                );
              
            % Generate signal matrix and put in place
            A(signalLocPerRow(s)+1:signalLocPerRow(s+1), 1:end) = ...
                signal; 
        end
 
        
        % --------------------------------------------------- Write Signals
        % Restructure Matrix
        dataLength = double(num_data_records)*double(recordWidth);
        A = reshape(A, dataLength,1);
        %A = reshape(A, num_data_records*recordWidth, 1);

        statusSignalCell = fwrite(fid, A, 'int16');
        if (myinput.debug)
            disp(['Wrote data int16: ' num2str(statusSignalCell)])
        end
    catch exception
        error(errMsg);
    end
end % End Signal Load Section

%---------------------------------------------------- Create return value
if nargout < 2
   varargout{1} = statusHeader + statusSignalHeader + statusSignalCell;
elseif nargout == 2
   varargout{1} = statusHeader;
   varargout{2} = signalHeader;
elseif nargout == 3
   varargout{1} = statusHeader;
   varargout{2} = signalHeader;
   varargout{3} = statusSignalCell;
end % End Return Value Function

% Close file explicitly
if fid > 0 
    fclose(fid);
end

%% end of blockEdfWrite part
end % End of blockEdfLoad function
