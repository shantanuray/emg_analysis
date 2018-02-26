# Analysis of EMG
## Overview
These are programs written to read, process and analyze EMG recordings
## Contents
* Main script for running the analysis
  * edf_analyze
* EDF Read library from Mathworks
  * edfread
* EDF Processing:
  * emgCleanup: Low pass filter and rectification
  * emgSelect: Select samples around annotations
  * movingAverage: Find the moving average
