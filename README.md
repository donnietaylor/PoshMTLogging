# PoshMTLogging

This simple module will write to a log file.  This module has a couple of unique features:

- Optional 'UseMutex' switch which helps avoid resource contention so multiple threads can write to the log at the same time
- Entry Severity make log readers like CMTrace color code automatically
- Standard line entry with automatic timestamping
- Automatic log rolling at 5mb
