# PoshMTLogging

A PowerShell module for writing log files with thread-safe support using Mutex.

## Features

- **Thread-Safe Logging**: Optional `UseMutex` switch to avoid resource contention, allowing multiple threads to write to the log simultaneously
- **Severity Levels**: Support for INFO, WARN, ERROR, and DEBUG levels (compatible with log readers like CMTrace for automatic color coding)
- **Automatic Timestamping**: Each log entry is automatically timestamped
- **Automatic Log Rolling**: Logs are automatically archived when they exceed 5MB

## Installation

### Manual Installation

1. Download the module files
2. Copy the `PoshMTLogging` folder to a PowerShell module path:
   - User-level: `$HOME\Documents\PowerShell\Modules\`
   - System-level: `$env:ProgramFiles\PowerShell\Modules\`
3. Import the module:

```powershell
Import-Module PoshMTLogging
```

## Usage

### Basic Usage

```powershell
Write-Log -text "Application started" -level INFO -log "C:\Logs\app.log"
```

### Logging with Different Severity Levels

```powershell
Write-Log -text "Starting process" -level INFO -log "C:\Logs\app.log"
Write-Log -text "Configuration value missing, using default" -level WARN -log "C:\Logs\app.log"
Write-Log -text "Failed to connect to database" -level ERROR -log "C:\Logs\app.log"
Write-Log -text "Variable value: $myVar" -level DEBUG -log "C:\Logs\app.log"
```

### Thread-Safe Logging

Use the `UseMutex` parameter when multiple threads or processes may write to the same log file:

```powershell
Write-Log -text "Thread-safe log entry" -level INFO -log "C:\Logs\shared.log" -UseMutex $true
```

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `text` | String | Yes | The main text to log |
| `level` | String | Yes | Severity level: INFO, WARN, ERROR, or DEBUG |
| `log` | String | Yes | Path to the log file |
| `UseMutex` | Boolean | No | Set to `$true` to enable thread-safe logging |

## Log Format

Each log entry is formatted as:

```
<timestamp>---<level>---<text>
```

Example output:

```
<date> <time>---INFO---Application started
<date> <time>---WARN---Configuration value missing
<date> <time>---ERROR---Failed to connect
```

## Log Rolling

When a log file exceeds 5MB, the module automatically:
1. Creates an archive copy with timestamp (e.g., `app.log.MM-DD-YY HH.MM.SS.archive`)
2. Clears the original log file for continued logging

## Requirements

- PowerShell 2.0 or later
- .NET Framework 2.0 or later

## Author

Created by Donnie Taylor
