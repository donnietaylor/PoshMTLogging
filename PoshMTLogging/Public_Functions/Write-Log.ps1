<#
	.SYNOPSIS
		Write to a log file with automatic log rolling and optional mutex support.
	
	.DESCRIPTION
		This function writes formatted log entries to a specified log file, prepending the 
		date/time and severity level to each entry. It supports automatic log rolling when 
		the file exceeds 5MB and optional mutex locking for thread-safe multi-threaded logging.
	
	.PARAMETER text
		The main text message to write to the log file. This is the content of the log entry.
	
	.PARAMETER level
		The severity level of the log entry. Valid values are:
		- INFO: Informational messages
		- WARN: Warning messages that indicate potential issues
		- ERROR: Error messages indicating failures
		- DEBUG: Debug messages for troubleshooting
	
	.PARAMETER log
		The full path to the log file. If the file does not exist, it will be created.
		When the log file exceeds 5MB, it is automatically archived with a timestamp.
	
	.PARAMETER UseMutex
		When set to $true, uses a system-wide mutex to prevent file access conflicts when 
		multiple threads or processes write to the same log file simultaneously.
		Default is $false.
	
	.INPUTS
		None. This function does not accept pipeline input.
	
	.OUTPUTS
		None. This function does not return any output.
	
	.EXAMPLE
		Write-Log -text "Application started successfully." -level INFO -log "C:\Logs\app.log"
		
		Writes an informational message to the log file.
	
	.EXAMPLE
		Write-Log -text "This is the main problem." -level ERROR -log "C:\Logs\app.log"
		
		Writes an error message to the log file.
	
	.EXAMPLE
		Write-Log -text "Processing complete." -level INFO -log "C:\Logs\app.log" -UseMutex $true
		
		Writes a message to the log file using mutex locking for thread-safe access.
	
	.EXAMPLE
		1..10 | ForEach-Object -Parallel {
			Import-Module PoshMTLogging
			Write-Log -text "Thread $_ running" -level DEBUG -log "C:\Logs\parallel.log" -UseMutex $true
		}
		
		Demonstrates thread-safe logging from multiple parallel threads using the UseMutex parameter.
	
	.NOTES
		Author: Donnie Taylor
		
		Log Format: <DateTime>---<Level>---<Message>
		
		Archive Format: When a log exceeds 5MB, it is copied to <logpath>.<timestamp>.archive
		and the original log is removed to start fresh.
#>
function Write-Log
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 0)]
		[ValidateNotNull()]
		[string]$text,
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[ValidateSet('INFO', 'WARN', 'ERROR', 'DEBUG')]
		[string]$level,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[string]$log,
		[Parameter(Position = 3)]
		[boolean]$UseMutex
	)
	
	Write-Verbose "Log:  $log"
	$date = (Get-Date).ToString()
	
	try
	{
		if (Test-Path $log)
		{
			$logItem = Get-Item $log -ErrorAction Stop
			if ($logItem.Length -gt 5mb)
			{
				$filenamedate = Get-Date -Format 'MM-dd-yy hh.mm.ss'
				$archivelog = ($log + '.' + $filenamedate + '.archive').Replace('/', '-')
				Copy-Item $log -Destination $archivelog -ErrorAction Stop
				Remove-Item $log -Force -ErrorAction Stop
				Write-Verbose "Rolled the log."
			}
		}
	}
	catch
	{
		Write-Error "Failed to process log file rotation: $_"
		return
	}
	
	$line = $date + '---' + $level + '---' + $text
	
	if ($UseMutex)
	{
		$LogMutex = $null
		try
		{
			$LogMutex = New-Object System.Threading.Mutex($false, "LogMutex")
			$LogMutex.WaitOne() | Out-Null
			$line | Out-File -FilePath $log -Append -ErrorAction Stop
		}
		catch
		{
			Write-Error "Failed to write to log file with mutex: $_"
		}
		finally
		{
			if ($null -ne $LogMutex)
			{
				try
				{
					$LogMutex.ReleaseMutex()
				}
				catch
				{
					Write-Error "Failed to release mutex: $_"
				}
			}
		}
	}
	else
	{
		try
		{
			$line | Out-File -FilePath $log -Append -ErrorAction Stop
		}
		catch
		{
			Write-Error "Failed to write to log file: $_"
		}
	}
}
