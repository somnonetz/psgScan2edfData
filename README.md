# psgScan2edfData

Converts polysomnographies to standardized edf via matlab structs. 

* `sn_edfScan2edfData`: Converts and EDF and writes it as a new EDF with standardized signal labels and - as an option - referenced signals
  * `sn_edfScan2matScan`: Reads EDF to matlab structs and cells
  * `sn_matScan2matData`: Does the actual conversion
  * `sn_matData2edfData`: writes the data back to EDF

## Getting started

### Prerequisites

You need a recent Matlab installation and the Signal Processing Toolbox on your computer. The application is tested with R2015b. 

### Pathes

Download the repo and add the directory `sn_psgScan2edfData` to your matlab-path. 

### Run the application

The basic function call is: `[status,header,signalHeader,signalCell,newheader,newsignalHeader,newsignalCell] = sn_edfScan2edfData('data',PATH-TO-EDF-FILE)`

Please check the documentation within the matlabfiles for further information. 







