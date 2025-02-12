function Start-mJig {

	#############################################################
	## mJig - An overly complex powershell mouse jiggling tool ##
	#############################################################

	<#    _                       __
		/   \                  /      \
	   '      \              /          \
	  |       |Oo          o|            |
	  `    \  |OOOo......oOO|   /        |
	   `    \\OOOOOOOOOOOOOOO\//        /
		 \ _o\OOOOOOOOOOOOOOOO//. ___ /
	 ______OOOOOOOOOOOOOOOOOOOOOOOo.___
	  --- OO'* `OOOOOOOOOO'*  `OOOOO--
		  OO.   OOOOOOOOO'    .OOOOO o
		  `OOOooOOOOOOOOOooooOOOOOO'OOOo
		.OO "OOOOOOOOOOOOOOOOOOOO"OOOOOOOo
	__ OOOOOO`OOOOOOOOOOOOOOOO"OOOOOOOOOOOOo
	___OOOOOOOO_"OOOOOOOOOOO"_OOOOOOOOOOOOOOOO
	 OOOOO^OOOO0`(____)/"OOOOOOOOOOOOO^OOOOOO
	 OOOOO OO000/00||00\000000OOOOOOOO OOOOOO
	 OOOOO O0000000000000000 ppppoooooOOOOOO
	 `OOOOO 0000000000000000 QQQQ "OOOOOOO"
	  o"OOOO 000000000000000oooooOOoooooooO'
	  OOo"OOOO.00000000000000000000OOOOOOOO'
	 OOOOOO QQQQ 0000000000000000000OOOOOOO
	OOOOOO00eeee00000000000000000000OOOOOOOO.
	OOOOOOOO000000000000000000000000OOOOOOOOOO
	OOOOOOOOO00000000000000000000000OOOOOOOOOO
	`OOOOOOOOO000000000000000000000OOOOOOOOOOO
	 "OOOOOOOO0000000000000000000OOOOOOOOOOO'
	   "OOOOOOO00000000000000000OOOOOOOOOO"
	.ooooOOOOOOOo"OOOOOOO000000000000OOOOOOOOOOO"
	.OOO"""""""""".oOOOOOOOOOOOOOOOOOOOOOOOOOOOOo
	OOO         QQQQO"'                     `"QQQQ
	OOO
	`OOo.
	`"OOOOOOOOOOOOoooooooo#>

    ###################
	## Ideas & Notes ##
	###################

	# Need More inconography in output.
	# Propper hidden option
	# stealth toggle for hiding ui (to be seperate from hidden option).
	# Add a routine to determine the direction the cursor moved and add a corosponding arrow emoji to the log. https://unicode.org/emoji/charts/full-emoji-list.html
	# Add indecator for current output mode in top bar

	param([Parameter(Mandatory = $false)] [string]$endTime = 2400,[Parameter(Mandatory = $false)] [string]$Output = "full")

	############
	## Config ## 
	############
	
		$defualtEndTime = 1807 # 4-digit 24 hour format ie. 1807=(6:07 PM). If no end time is provided this default time will be used
		$defualtEndMaxVariance = 15 # A defualt max tolerance in Minutes. Randomly adds or sutracts a set number of minutes from the defaultEndTime to avoid overly consistant end times. (Does not apply if end time is specified.)

		$intervalSeconds = 5 # sets the base interval time between refreshes
		$intervalVariance = 2 # Sets the maximum random plus and minus variance in seconds each refresh

	############
	## Preparing ##
	############ 

	# Prep the Host Console #
	[Console]::CursorVisible = $false
	Clear-Host
	if ($Output -ne "hidden") {

		# Capture Initial Buffer & Window Sizes #
		$pshost = Get-Host
		$pswindow = $pshost.UI.RawUI
		$newBufferSize = $pswindow.BufferSize
		$newWindowSize = $pswindow.WindowSize
		$hostWidth = $newBufferSize.Width
		$hostHeight = $newBufferSize.Height

		# Initialize the Output Array #
		$logArray = @()
	}

	###############################
	## Calculating the End Times ##
	###############################
	<#⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
	⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⡾⠿⢿⡀⠀⠀⠀⠀⣠⣶⣿⣷⠀⠀⠀⠀
	⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣦⣴⣿⡋⠀⠀⠈⢳⡄⠀⢠⣾⣿⠁⠈⣿⡆⠀⠀⠀
	⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⠿⠛⠉⠉⠁⠀⠀⠀⠹⡄⣿⣿⣿⠀⠀⢹⡇⠀⠀⠀
	⠀⠀⠀⠀⠀⣠⣾⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⣰⣏⢻⣿⣿⡆⠀⠸⣿⠀⠀⠀
	⠀⠀⠀⢀⣴⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣆⠹⣿⣷⠀⢘⣿⠀⠀⠀
	⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠋⠉⠛⠂⠹⠿⣲⣿⣿⣧⠀⠀
	⠀⢠⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣿⣿⣿⣷⣾⣿⡇⢀⠀⣼⣿⣿⣿⣧⠀
	⠰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⡘⢿⣿⣿⣿⠀
	⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⣷⡈⠿⢿⣿⡆
	⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠁⢙⠛⣿⣿⣿⣿⡟⠀⡿⠀⠀⢀⣿⡇
	⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣶⣤⣉⣛⠻⠇⢠⣿⣾⣿⡄⢻⡇
	⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣦⣤⣾⣿⣿⣿⣿#>
	
	$endTime = $defualtEndTime
	if ($endTime -ge 0000 -and $endTime -le 2400 -and $endTime.Length -eq 4) {
		Add-Type -AssemblyName System.Windows.Forms
		$WShell = New-Object -com "Wscript.Shell"
		if ($endTime -eq 2400) {
			$ras = Get-Random -Maximum 3 -Minimum 1
			if ($ras -eq 1) {
				$endTime = ($DefualtEndTime - (Get-Random -Maximum $defualtEndMaxVariance))
			} else {
				$endTime = ($DefualtEndTime + (Get-Random -Maximum $defualtEndVariance))
			}
		}
		$currentTime = Get-Date -Format "HHmm"
		if ($endTime -le $currentTime) {
			$tommorow = (Get-Date).AddDays(1)
			$endDate = Get-Date $tommorow -Format "MMdd"
		} else {
			$endDate = Get-Date -Format "MMdd"
		}
		$end = "$endDate$endTime"
		$time = $false

		# Start your engines #

		:process do {
			$outputline = 0
			$oldRows = $rows
			$rows = $hostHeight - 6
			$oldLogArray = $logArray
			$logArray = @()
			if ($oldRows -ne $rows) {
				if ($oldRows -lt $rows) {
					$insertArray=@()
					$row = [PSCustomObject]@{
						logRow = "insert"
						value = $null
					}
					for ($i = $rows; $i -gt $oldRows-1; $i--) {
						$insertArray += $row
					}
					$oldLogArray = $insertArray + $oldLogArray
				} else {
					$oldLogArray = $oldLogArray[-($oldRows-($oldRows-$rows))..-1]
				}
			}
			for ($i = $rows; $i -ge 1; $i--) {
				if ($i -ne 1) {
					$row = [PSCustomObject]@{
						logRow = "$i"
						value = $oldLogArray[$rows-$i+1].value
					}
				} else {
					$row = [PSCustomObject]@{
						logRow = "$i"
						value = $date
					}
				}
					$LogArray += $row
			}
			if ($skipUpdate -ne $true) {
				$pos = [System.Windows.Forms.Cursor]::Position
				if ($pos -eq $lastPos) {
					$posUpdate = $true
					$rx,$ry,$rasX,$rasy = (Get-Random -Maximum 300),(Get-Random -Maximum 300),(Get-Random -Maximum 2),(Get-Random -Maximum 2)
					if ($rasX -eq 1) {
						$x = $pos.X + $rx
					} else {
						$x = $pos.X - $rx
					}
					if ($rasY -eq 1) {
						$y = $pos.Y + $ry
					} else {
						$y = $pos.Y - $ry
					}
					$WShell.sendkeys("{SCROLLLOCK}")
					Start-Sleep -Milliseconds 100
					$WShell.sendkeys("{SCROLLLOCK}")

					[System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point ($x,$y)
				} else {
					$posUpdate = $false
				}
				$lastPos = [System.Windows.Forms.Cursor]::Position
			}

			# Output Handling #

			# header
			if ($Output -ne "hidden") {
				# output blank line
				$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{clear-host;$t=$false}finally{
					if($t) {
						for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
							write-host " " -NoNewline
						}
					}
				}
				$Outputline++

				# output header
				$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{$t=$false}finally{
					if($t) {
						Write-Host "  mJig(`u{1F400})" -NoNewline -ForegroundColor Magenta
						Write-Host " ➢  " -NoNewline
						Write-Host "End`u{23F3}/" -NoNewline -ForegroundColor yellow
						Write-Host "$endTime" -NoNewline -ForegroundColor Green
						Write-Host " ➣  " -NoNewline
						Write-Host "Current`u{23F3}/" -NoNewline -ForegroundColor Yellow
						Write-Host "$currentTime" -ForegroundColor Green -NoNewline
						if ($Output -eq "dib") {
							write-host " (DiB)" -ForeGroundColor Magenta -NoNewline
						} elseif ($Output -eq "full") {
							write-host " (Ful)" -ForeGroundColor Magenta -NoNewline
						} else {
							write-host " (Min)" -ForeGroundColor Magenta -NoNewline
						}
						for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
							write-host " " -NoNewline
						}
					}
				}
				$Outputline++

				# Output Line Spacer
				$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{$t=$false}finally{
					if($t) {
						for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
							Write-Host " " -NoNewLine
							write-host ("─" * ($hostWidth - 2)) -ForegroundColor White -NoNewline
							for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
								write-host " " -NoNewline
							}
						}
					}
				}
				$outputLine++

				# Output Line Spacer
				if ($skipUpdate -ne $true) {
					if ($posUpdate -eq $false) {
						$logOutput = "input detected, skipping update"
					} else {
						$logOutput = "cooridinates update x$x/y$y"
					}
					$log = "   $logOutput"
				}
				if ($output -ne "min") {
					for ($i = $rows; $i -gt 0; $i--) {
						$date = get-date
						$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{$t=$false}finally{
							if($t) {
								if ($i -ne 1) {
									$row = [PSCustomObject]@{
										logRow = $true
										value = $oldLogArray[$rows-$i+1].value
									}
								} else {
									$row = [PSCustomObject]@{
										logRow = $true
										value = $date
									}
								}
							}
							$logArray += $row
							write-host $logArray[$rows-$i].value
						}
						$outputLine++
					}
				}
			}


			$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{$t=$false}finally{
				if($t) {
					for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
						Write-Host " " -NoNewLine
						write-host ("─" * ($hostWidth - 2)) -ForegroundColor White -NoNewline
						for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
							write-host " " -NoNewline
						}
					}
				}
			}
			$outputLine++

			## Menu Options ##
			$t=$true;try{[Console]::SetCursorPosition(0,$Outputline)}catch{$t=$false}finally{
				if($t) {
					write-host "  " -NoNewLine
					write-host "`u{1F39A}`u{FE0F}" -NoNewLine
					write-host "(" -NoNewline -ForegroundColor White
					write-host "t" -ForegroundColor Yellow -NoNewline
					write-host ")" -NoNewLine  -ForegroundColor White
					write-host "oggle_output " -ForegroundColor Green -nonewline
					write-host "`u{1FAE3}" -NoNewline
					write-host "(" -NoNewLine  -ForegroundColor White
					write-host "h" -ForegroundColor Yellow -NoNewline
					write-host ")" -ForegroundColor White -NoNewline
					write-host "ide_output" -ForegroundColor Green -NoNewline
					write-host (" " * ($hostWidth - 46)) -NoNewLine
					write-host "`u{1F400}" -NoNewline
					write-host "(" -NoNewLine  -ForegroundColor White
					write-host "q" -ForegroundColor Yellow -NoNewline
					write-host ")" -NoNewLine
					write-host "uit" -ForegroundColor Green -NoNewline
					for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
						write-host " " -NoNewline
					}
				}
			}
			$Outputline++

			$ras = Get-Random -Maximum 3 -Minimum 1
			if ($ras -eq 1) {
				$interval = ($intervalSeconds - (Get-Random -Maximum $intervalVariance))
			} else {
				$interval = ($intervalSeconds + (Get-Random -Maximum $intervalVariance)) 
			}
			$currentTime = Get-Date -Format "HHmm"
			$current = Get-Date -Format "MMddHHmm"
			if ($current -ge $end) {
				$time = $true
			}
			## Menu/Hotkey Loop ##
			$math = $interval * 2
			$x = 0
			$skipUpdate = $false
			:menu do {
				if ($Host.UI.RawUI.KeyAvailable) {
					$keyPress = $Host.UI.RawUI.ReadKey("IncludeKeyup,NoEcho").Character
					if ($keyPress -eq "q") {
						$Outputline--
						[Console]::SetCursorPosition(0,$Outputline)
						Write-Host " " -nonewline
						Write-Host "force quit" -BackgroundColor DarkRed -NoNewline
						for ($i = $Host.UI.RawUI.CursorPosition.x; $i -lt $hostWidth; $i++) {
							write-host " " -NoNewline
						}
						write-host
						write-host
						return
					} elseif ($keyPress -eq "t") {
						if ($Output -eq "full") {
							$Output = "min"
						} else {
							$Output = "full"
						}
						$skipUpdate = $true
						continue process
					}
				} elseif ($Output -ne "off") {
					$pshost = Get-Host
					$pswindow = $pshost.UI.RawUI
					$newBufferSize = $pswindow.BufferSize
					$newWindowSize = $pswindow.WindowSize
					if (($newBufferSize -ne $oldBufferSize) -or ($newWindowSize -ne $oldWindowSize)) {
						$oldBufferSize = $newBufferSize
						$oldWindowSize = $newWindowSize
						$hostWidth = $newBufferSize.Width
						$hostHeight = $newBufferSize.Height
						$skipUpdate = $true
						clear-host
						continue process
					}
				}
				$x++
				start-sleep -m 200
			} until ($x -eq $math)
		} until ($time -eq $true)
		if ($output -ne "no") {
			[Console]::SetCursorPosition(0,$Outputline)
			Write-Host "       END TIME REACHED: " -NoNewline -ForegroundColor Red
			Write-Host "Stopping " -NoNewline
			Write-Host "mJig"
			write-host
		}
	} else {
		Write-Host "use 4-digit 24hour time format"
		Write-Host
	}
}
Start-mJig -Output dib