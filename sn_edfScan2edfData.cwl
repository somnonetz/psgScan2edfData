cwlVersion: v1.0
class: CommandLineTool
baseCommand: run_sn_edfScan2edfData.sh

inputs:
  data:
    type: File
    inputBinding:
      prefix: data
    doc: "path to edf-file"
  outputfilebase:
    type: string?
    inputBinding:
      prefix: outputfilebase
    doc: "outputfilebase for final output edf"
  subjectid:
    type: string
    inputBinding:
      prefix: subjectid
    doc: "subject identifier to allow setting in header.patient_id"
  gender:
    type: string?
    inputBinding:
      prefix: gender
    doc: "gender of the subject: 'M'(male),'F'(female),'O'(other),'U'(unknown) default: X"
  dob:
    type: string?
    inputBinding:
      prefix: dob
    doc: "day of birth in dd-MMM-yyy, e.g. 01-JAN1999, default: X"
  localrecordid:
    type: string?
    inputBinding:
      prefix: localrecordid
    doc: "id of the recording, default: X"
  institution:
    type: string?
    inputBinding:
      prefix: institution
    doc: "name of the clinics the data was acquired, default: X"
  device:
    type: string?
    inputBinding:
      prefix: device
    doc: "name of the device or of the manufacturer, default: X"
  modifyheader:
    type: int?
    inputBinding:
      prefix: modifyheader
    doc: "If set to zero, header should not be modified, otherwise modified to edf+ conformance, default: 1"
  modifyreference:
    type: int?
    inputBinding:
      prefix: modifyreference
    doc: "If set to one, try standardized signal references, such as combine F1 and A2 to EEG F1-A2, default: 0"
  xnat:
    type: int?
    inputBinding:
      prefix: xnat
    doc: "If set to one, xnat metadata files are written, default: 0"
  mapfile:
    type: File?
    inputBinding:
      prefix: mapfile
    doc: "Path of file with standard labels and channels, default: ./psg_channelmap.txt"
  debug:
    type: int?
    inputBinding:
      prefix: debug
    doc: "if set to 1 debug information is provided. Default 0"
 
outputs:
  outputfile:
    type: File
    outputBinding:
      glob: "*.edf"
    doc: "The standardized edf"
