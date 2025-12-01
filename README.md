# PoshMTLogging

This simple module will write to a log file.  This module has a couple of unique features:

- Optional 'UseMutex' switch which helps avoid resource contention so multiple threads can write to the log at the same time
- Entry Severity make log readers like CMTrace color code automatically
- Standard line entry with automatic timestamping
- Automatic log rolling at 5mb
- Error handling for file operations and mutex management

## Installation

Import the module directly from the local path:

```powershell
Import-Module ./PoshMTLogging/PoshMTLogging.psd1
```

## Usage

### Basic Logging

```powershell
Write-Log -text "Application started successfully." -level INFO -log "C:\Logs\app.log"
Write-Log -text "Configuration file not found, using defaults." -level WARN -log "C:\Logs\app.log"
Write-Log -text "Failed to connect to database." -level ERROR -log "C:\Logs\app.log"
Write-Log -text "Variable value: 42" -level DEBUG -log "C:\Logs\app.log"
```

### Thread-Safe Logging with Mutex

When logging from multiple threads or processes, use the `-UseMutex` parameter to prevent file access conflicts:

```powershell
Write-Log -text "Processing complete." -level INFO -log "C:\Logs\app.log" -UseMutex $true
```

### Parallel Logging Example

```powershell
1..10 | ForEach-Object -Parallel {
    Import-Module PoshMTLogging
    Write-Log -text "Thread $_ running" -level DEBUG -log "C:\Logs\parallel.log" -UseMutex $true
}
```

## Log Format

Each log entry follows the format:

```
<DateTime>---<Level>---<Message>
```

Example output:
```
12/01/2025 10:30:15---INFO---Application started successfully.
12/01/2025 10:30:16---WARN---Configuration file not found, using defaults.
12/01/2025 10:30:17---ERROR---Failed to connect to database.
```

## Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| text | Yes | The main text message to write to the log file |
| level | Yes | Severity level: INFO, WARN, ERROR, or DEBUG |
| log | Yes | Full path to the log file |
| UseMutex | No | Set to $true for thread-safe logging (default: $false) |

## Automatic Log Rolling

When a log file exceeds 5MB, it is automatically archived with a timestamp and a new log file is started. The archive file follows the naming pattern:

```
<logpath>.<MM-dd-yy hh.mm.ss>.archive
```

