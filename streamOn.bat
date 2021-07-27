echo off
set desc=%1
set rtsp=%2
set key=%3
set log=%4
set desc=%desc:"='%
set title=%desc:"=%
set key=%key:"=%
TITLE %title% [ONLINE]
echo on 

C:\SN_Scripts\RtspToYoutubeStream\ffmpeg.exe -f lavfi -thread_queue_size 1024 -i anullsrc=channel_layout=stereo:sample_rate=44100 -thread_queue_size 1024 -rtsp_transport tcp -i %rtsp% -thread_queue_size 1024 -i "C:\SN_Scripts\RtspToYoutubeStream\belka.png" -filter_complex "[1:v]scale='1280:720'[ovrl],[ovrl][2:v] overlay='2:(H-h)',drawtext=text=%desc%:fontfile='/SN_Scripts/RtspToYoutubeStream/OpenSans-Bold.ttf':fontsize=25:fontcolor=black:x='(W*0.16)':y='(H*0.9125)',drawtext=text='%%{localtime\:%%X}':fontfile='/SN_Scripts/RtspToYoutubeStream/OpenSans-Regular.ttf':fontsize=18:fontcolor=white:x='(W*0.06)':y='(H*0.884)'" -vcodec libx264 -pix_fmt yuvj422p -preset veryfast -r 10 -g 20 -b:v 1000k -c:a aac -map 0:a -map 1:v -map 2 -f flv "rtmp://a.rtmp.youtube.com/live2/%key%" 2> %log%