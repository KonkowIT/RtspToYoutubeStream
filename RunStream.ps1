[CmdletBinding()] Param(
    [string] $ip,
    [int32] $port,
    [string] $rtsp,
    [string] $key,
    [string] $desc
)

$PSDefaultParameterValues['*:Encoding'] = 'utf8'
$host.UI.RawUI.WindowTitle = "$desc - Youtube stream"

# SCHEDULED TASK EXAMPLE
# 'Program/Skrypt': powershell.exe
# 'Argumenty': -file "C:\SN_Scripts\RtspToYoutubeStream\RunStream.ps1" -ip "IP" -port PORT -rtsp "ADRES_RTSP" -key "YOUTUBE_KLUCZ" -desc "PODPIS"

function CheckProcessFfmppeg($k) {
    return Get-WMIObject -Class Win32_Process -Filter "Name='ffmpeg.EXE'" | Where-Object { $_.commandline -like "*$k*" }
}

function CheckProcessCmd($k) {
    return Get-WMIObject -Class Win32_Process -Filter "Name='cmd.EXE'" | Where-Object { $_.commandline -like "*$k*" }
}

function GetFrames($l) {
    if (Test-Path $l) {
        $v = Get-Content $l -Tail 1
        return [regex]::match($v,".*frame=(.*)fps.*").groups[1].value.trim()
    }
    else {
        return 0
    }
}

if ($desc -like "*-*") {
    $descLog = $desc.split('-')[1]
}
else {
    $descLog = $desc
}

$log = -join("C:\SN_Scripts\RtspToYoutubeStream\FFMPEG_LOG_", ($descLog.replace(' ','').replace('.','').replace(',','').replace('_','').replace('/','').replace('\','').replace('[','').replace(']','').replace('{','').replace('}','').replace('(','').replace(')','')), ".txt")

Set-Variable -name "frame" -Scope Global -Value 1

do {
    Start-Sleep -s 5
    $tcpobject = new-Object system.Net.Sockets.TcpClient 
    $connect = $tcpobject.BeginConnect($ip, $port, $null, $null) 
    $wait = $connect.AsyncWaitHandle.WaitOne(2000, $false) 
    $proc = @( CheckProcessFfmppeg -k $key )
    $proc = $proc + ( CheckProcessCmd -k $key )

    If (-Not $Wait) {
        -join("`n", $(Get-date)," - Rozlaczony")
        $frame = 1
        
        if ($null -ne ($proc | Where-Object {$_.commandline -like "*$rtsp*" })) {
            "Zamykanie procesu FFMPEG stream online"
            $proc | ForEach-Object { Stop-process -Id $_.Handle -Force }
        }

        if ($null -eq ($proc | Where-Object {$_.commandline -like "*streamOffline*" })) {
            "Uruchamianie zastepczego streamu offline"
            Start-Process cmd.exe -WindowStyle Minimized -ArgumentList "/c", "C:\SN_Scripts\RtspToYoutubeStream\streamOff.bat", "`"$desc`"", "`"$key`"", "`"$log`""
        }
        else {
            "Zastepczy stream offline z jest juz uruchomiony"
        }
    }
    Else {
        $error.clear()
        $tcpobject.EndConnect($connect) | out-Null 
        If ($Error[0]) {
            Write-warning ("{0}" -f $error[0].Exception.Message)
        }
        Else {
            -join("`n", $(Get-date)," - Polaczony")

            if ($null -ne ($proc | Where-Object {$_.commandline -like "*streamOffline*" })){
                "Zamykanie procesu zastepczego streamu offline"
                $proc | ForEach-Object { Stop-process -Id $_.Handle -Force }
            }

            if ((GetFrames -l $log) -eq $frame) {
                "Zamykanie procesu streamu, przestal wysylac frame'y"
                $proc | ForEach-Object { Stop-process -Id $_.Handle -Force }
            }

            $frame = 1
            
            if ($null -eq ($proc | Where-Object {$_.commandline -like "*$rtsp*" })) {
                
                if (Test-Path $log) { Remove-item $log -Force -ErrorAction SilentlyContinue}

                "Uruchamianie streamu z kamery $ip`:$port"
                Start-Process cmd.exe -WindowStyle Minimized -ArgumentList "/c", "C:\SN_Scripts\RtspToYoutubeStream\streamOn.bat", "`"$desc`"", "`"$rtsp`"", "`"$key`"", "`"$log`""
            }
            else {
                "Stream z kamery $ip`:$port jest juz uruchomiony"
                $v = Get-Content $log -Tail 1
                $frame = GetFrames -l $log
            }
        }
    }
}
while ($true)