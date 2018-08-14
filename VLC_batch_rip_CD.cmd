@ECHO OFF

REM This batch file allows you to rip all tracks from an audio CD to MP3 or WAV.
REM However, it must be adapted to the individual circumstances.

REM *****     enter after "CD " the installation directory of vlc.exe             *****
CD C:\Program Files\VideoLAN\VLC\

REM *****     enter after "SET s=" the source directory for the optical drive     *****
SET s=D:\

REM *****     enter after "SET p=" the destination directory for ribbed tracks    *****
SET p=C:\Users\Keith\Downloads\AudioRip

REM *****     enter after "SET m=" for conversion to MP3 > "MP3", to WAV > "WAV"  *****
SET m=MP3


SETLOCAL ENABLEDELAYEDEXPANSION

SET /a n=0
SET f=""

FOR /R %s% %%L IN (*.cda) DO (CALL :sub_transcode "%%L")

GOTO :eof

:sub_transcode
Call SET /a n=n+1

ECHO Transcoding %1

   IF !n! LEQ 9 (GOTO :with_zero) ELSE (GOTO :without_zero)

:with_zero
   CALL SET f=%p%Track_0!n!.mp3
   GOTO :transcode
   
:without_zero   
   CALL SET f=%p%Track_!n!.mp3

:transcode
   if /i %m%==MP3 (
      CALL vlc -I http cdda:///%s% --cdda-track=!n! :sout=#transcode{vcodec=none,acodec=mp3,ab=128,channels=2,samplerate=44100}:std{access="file",mux=raw,dst=!f!} vlc://quit
   ) ELSE (
      CALL vlc -I http cdda:///%s% --cdda-track=!n! :sout=#transcode{vcodec=none,acodec=s16l,ab=224,channels=2,samplerate=48000}:std{access="file",mux=wav,dst=!f!.wav} vlc://quit
   )
:eof