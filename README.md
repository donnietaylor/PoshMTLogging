# PoshMTLogging

A PowerShell 7.x logging module that provides thread-safe logging capabilities with automatic log rotation and CMTrace-compatible formatting.

## Features

- **Thread-Safe Logging**: Optional mutex-based locking prevents resource contention when multiple threads write simultaneously
- **CMTrace Compatible**: Severity levels (INFO, WARN, ERROR, DEBUG) enable automatic color-coding in CMTrace and similar log readers
- **Automatic Timestamping**: Each log entry includes a timestamp in the format `MM/dd/yyyy HH:mm:ss`
- **Automatic Log Rolling**: Logs are automatically rolled over when they reach 5MB, creating timestamped archive files
- **PowerShell 7.x Compatible**: Fully compatible with PowerShell 7.0 and later versions

## Requirements

- PowerShell 7.0 or later

## Installation

### Manual Installation

1. Download the module files
2. Copy the `PoshMTLogging` folder to one of your PowerShell module paths:
   - User scope: `$HOME/Documents/PowerShell/Modules/`
   - System scope: `$env:ProgramFiles/PowerShell/Modules/`

3. Import the module:
```powershell
Import-Module PoshMTLogging
```

### Verify Installation

```powershell
Get-Module PoshMTLogging
Get-Command -Module PoshMTLogging
```

## Usage

### Basic Logging

Write a simple log entry:

```powershell
Write-Log -text "Application started successfully" -level INFO -log "C:\logs\app.log"
```

### Log Levels

The module supports four severity levels:

- **INFO**: Informational messages
- **WARN**: Warning messages
- **ERROR**: Error messages
- **DEBUG**: Debug messages

```powershell
Write-Log -text "User logged in" -level INFO -log "C:\logs\app.log"
Write-Log -text "Disk space running low" -level WARN -log "C:\logs\app.log"
Write-Log -text "Failed to connect to database" -level ERROR -log "C:\logs\app.log"
Write-Log -text "Variable value: $myVar" -level DEBUG -log "C:\logs\app.log"
```

### Thread-Safe Logging with Mutex

When logging from multiple threads or jobs, use the `-UseMutex` parameter to prevent write conflicts:

```powershell
# Single-threaded (no mutex needed)
Write-Log -text "Single thread message" -level INFO -log "C:\logs\app.log"

# Multi-threaded scenario
$jobs = 1..5 | ForEach-Object {
    Start-Job -ScriptBlock {
        param($i)
        Import-Module PoshMTLogging
        Write-Log -text "Job $i writing to log" -level INFO -log "C:\logs\app.log" -UseMutex $true
    } -ArgumentList $_
}

$jobs | Wait-Job | Remove-Job
```

### Automatic Log Rolling

When a log file reaches 5MB, the module automatically:
1. Creates an archive copy with timestamp: `app.log.MM-dd-yy hh.mm.ss.archive`
2. Removes the original file
3. Starts a new log file

Example of log files after rolling:
```
app.log
app.log.12-09-25 02.30.15.archive
app.log.12-08-25 14.22.10.archive
```

### Log Entry Format

Each log entry follows this format:
```
MM/dd/yyyy HH:mm:ss---LEVEL---message text
```

Example:
```
12/09/2025 21:49:08---INFO---Application started successfully
12/09/2025 21:49:10---WARN---Disk space at 85%
12/09/2025 21:49:15---ERROR---Connection timeout
```

## Function Reference

### Write-Log

Writes a formatted log entry to a specified log file.

#### Parameters

- **text** (Mandatory, Position 0)
  - Type: String
  - The message text to log

- **level** (Mandatory, Position 1)
  - Type: String
  - Valid values: INFO, WARN, ERROR, DEBUG
  - The severity level of the log entry

- **log** (Mandatory, Position 2)
  - Type: String
  - The full path to the log file

- **UseMutex** (Optional, Position 3)
  - Type: Boolean
  - Default: $false
  - Set to $true for thread-safe logging in multi-threaded scenarios

#### Examples

```powershell
# Basic usage
Write-Log -text "This is a test message" -level INFO -log "C:\logs\test.log"

# With positional parameters
Write-Log "This is a test message" INFO "C:\logs\test.log"

# Thread-safe logging
Write-Log -text "Multi-thread message" -level INFO -log "C:\logs\test.log" -UseMutex $true

# With verbose output
Write-Log -text "Debug message" -level DEBUG -log "C:\logs\test.log" -Verbose
```

## Compatibility Notes

### PowerShell 7.x

This module is designed for PowerShell 7.0 and later. Key compatibility considerations:

- Uses PowerShell Core compatible cmdlets and syntax
- Thread-safe mutex implementation works on both Windows and cross-platform PowerShell installations
- File paths support both Windows and Unix-style paths

### CMTrace Integration

Log entries are formatted for compatibility with Microsoft's CMTrace tool:
- The severity level enables automatic color-coding
- Timestamp format is consistent with CMTrace expectations

## License

Copyright (c) 2016. All rights reserved.

## Author

Created by Donnie Taylor
