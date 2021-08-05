# RtspToYoutubeStream
Script creating stream on Youtube from raw rtsp with safety board when connection with camera is lost.

* It is necessary to put 'ffmpeg.exe' in script directory.

* To automate script launching create task in Windows Task Scheduler</br>
Program/Script: powershell.exe</br>
Argumenty: -file "C:\SN_Scripts\RtspToYoutubeStream\RunStream.ps1" -ip "RTSP_IP" -port RTSP_PORT -rtsp "RTSP" -key "KEY" -desc "DESCRIPTION"</br>

</br>
<p align="center">
  <b>Online</b>
  <img src="https://github.com/KonkowIT/RtspToYoutubeStream/blob/main/img/online.jpg" width="600"></br></br>
  <b>Offline</b>
  <img src="https://github.com/KonkowIT/RtspToYoutubeStream/blob/main/img/offline.jpg" width="600"></br>
</p>
