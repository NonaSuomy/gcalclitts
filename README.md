# gcalclitts
GCalCLI + Google TTS (Online) + Pico2Wave [svox-pico-bin] (Offline) - Google Calendar Text To Speech

## Raspberry Pi (OSMC) setup

```sh
ssh osmc@10.13.37.100
password: osmc
```
Install gcalcli with pip.
```sh
osmc@OSMC001:~$ sudo pip install gcalcli vobject parsedatetime
```
Authorize gcalcli to use your calendar.
```sh
osmc@OSMC001:~$ gcalcli list --noauth_local_webserver
```
A link will apear, you will have to open it in your local web browser.  Obtain a verification number, which you will have to enter the code in the console.
That will authorize gcalcli usage of your Google Calendar.

> **Note:** *Make a simple calendar in your Google Calendar that gcalcli can parse some events from. It will say what ever you put in the Title not the discription Title: "Hello Family, It's recycling and garbage collection tomorrow"*

Test gcalcli list

```sh
osmc@OSMC001:~$ gcalcli list
 Access  Title
 ------  -----
  owner  youremail@gmail.com
  owner  Work Hours
  owner  AutomationReminder
 reader  Work Calendar
 reader  Garbage Pickup
 reader  anothersemail@gmail.com
 reader  Contacts
 reader  Holidays in Country
 reader  Phases of the Moon
 reader  Sunrise/Sunset: City
 reader  Weather: 000000
```

Test gcalcli agenda.
```sh
osmc@OSMC001:~$ gcalcli --calendar="AutomatedReminder" agenda

Thu Oct 07           Hello family it is Garbage Day Tomorrow

Fri Oct 08             Hello again. just a reminder it's Garbage Day!
```

> **Note:** *Make sure to have events in your calendar or else you will get "No Events Found...".*

Install svox-pico (Best free offline TTS so far, it's ported from Android) other wise you can use it's robotic cousin espeak.
```sh
osmc@OSMC001:~$ sudo apt-get install libttspico-utils
```

Test pico2wave:
```sh
osmc@OSMC001:~$ pico2wave ---wave=test.wav "This is a test"
osmc@OSMC001:~$ aplay test.wav
```

Install some audio players to use with our sample effects and tts audio files.
 - mpg123 to play Google TTS mp3 audio files.
 - libvorbis-tools to play ogg audio files.
 - sox (play) or alsa-utils (aplay) to play pico2wave wav audio files.
 - iputils-ping is possibly already installed.  This is for the script to detect if we are online, if not use offline TTS.

```sh
osmc@OSMC001:~$ sudo apt-get install mpg123 vorbis-tools sox alsa-utils iputils-ping
```
> **Note:** *Make sure to test the players with a sample audio file and ping utils before running the script.*

Download a pre-notification audible prompt sound effect, it will play this sample sound before it announces your message.

Make directory for sound effect.
```sh
osmc@OSMC001:~$ sudo mkdir -p /usr/share/sounds/gnome/default/alert
```
Download sound to folder we made.
```sh
osmc@OSMC001:~$ sudo wget -O /usr/share/sounds/gnome/default/alert/glass.ogg https://github.com/GNOME/gnome-control-center/raw/master/panels/sound/data/sounds/glass.ogg
```
> **Note:** *There are some download locations to more sounds in the source of the gcalclitts.sh script.*

Download gcalclitts.sh tts script
```sh
osmc@OSMC001:~$ wget https://raw.githubusercontent.com/NonaSuomy/gcalclitts/master/gcalclitts.sh
```
Make gcalclitts.sh executable.
```sh
osmc@OSMC001:~$ chmod u+x gcalclitts.sh
```
Edit gcalclitts.sh with the Calendar name you want to use that you got from gcalcli list.
```sh
osmc@OSMC001:~$ nano ~/gcalclitts.sh
# Settings:

# To get a list of calendars with your account type gcalcli list, 
# If you rencently added a calendar first type gcalcli list --refresh 
# and gcalcli agenda --refresh
calname="AutomationReminder"
```
> **Note:** *There is a few options (Player and different App for TTS Offline) commented out in the code that you can change to your liking.*

Run the script.
```sh
osmc@OSMC001:~$ ~/gcalclitts.sh
```
If everything is working as it should then you should hear..
```sh
*Ding
*Hello Family, it's garbage day tomorrow.
```
### Run script with something

Install cron
```sh
osmc@OSMC001:~$ sudo apt-get update
osmc@OSMC001:~$ sudo apt-get install cron
```
Edit cron
```sh
osmc@OSMC001:~$ crontab -e
no crontab for osmc - using an empty one

/usr/bin/select-editor: 1: /usr/bin/select-editor: gettext: not found
 'select-editor'.
/usr/bin/select-editor: 1: /usr/bin/select-editor: gettext: not found
  1. /bin/nano        <---- 
  2. /usr/bin/mcedit

/usr/bin/select-editor: 32: /usr/bin/select-editor: gettext: not found
 1-2 [1]: 1
crontab: installing new crontab
```
Add cron job to run the script every night at 10PM.
```sh
osmc@OSMC001:~$ crontab -e
0 22 * * * /home/osmc/gcalclitts.sh
```
[![N|Solid](http://i.stack.imgur.com/BeXHD.jpg)](http://stackoverflow.com/questions/8938120/how-to-run-cron-once-daily-at-10pm)

### Troubleshooting

I was getting this error in the console: `ALSA lib pcm.c:2217:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.front` which I wanted to be silent.  The information worked below to fix it. Only required to edit alsa.conf the rest of the stuff is just extra information in case I found another issue.

**Raspberry Pi – Getting Audio Working.**

Alsa, Audio, Lame, Mp3, Mpg321, Raspberry Pi, Sound, Wav
 
How to get the audio working on your Raspberry Pi.

Install three packages.

ALSA utilities:
```sh
osmc@OSMC001:~$ sudo apt-get install alsa-utils
```
MP3 tools:
```sh
osmc@OSMC001:~$ sudo apt-get install mpg321
```
WAV to MP3 conversion tool:
```sh
osmc@OSMC001:~$ sudo apt-get install lame
```
Load the sound driver:
```sh
osmc@OSMC001:~$ sudo modprobe snd-bcm2835
```
To check if the driver is loaded you can type:
```sh
osmc@OSMC001:~$ sudo lsmod | grep 2835
```
Select the output device for sound (0=auto, 1=analog, 2=HDMI):
```sh
osmc@OSMC001:~$ sudo amixer cset numid=2
```
Test the installation:
```sh
osmc@OSMC001:~$ aplay /usr/share/sounds/alsa/Front_Center.wav
osmc@OSMC001:~$ speaker-test -t sine -f 440 -c 2 -s 1
osmc@OSMC001:~$ mpg321 “random.mp3”
```

**If you get the following error message:**
```sh
ALSA lib pcm.c:2217:(snd_pcm_open_noupdate) Unknown PCM cards.pcm.front
```
**Edit the file /usr/share/alsa/alsa.conf:**
```sh
osmc@OSMC001:~$ sudo nano /usr/share/alsa/alsa.conf
```
**Change the line “pcm.front cards.pcm.front” to “pcm.front cards.pcm.default”**


If you are using HDMI and cannot hear any audio at all change the following RPi configuration setting.

Edit the Rasberry Pi configuration file.
```sh
osmc@OSMC001:~$ sudo nano /boot/config.txt
```
Uncomment the line.
```sh
hdmi_drive=2
```
Save the file and reboot the RPi.

### Resources
https://github.com/insanum/gcalcli
http://cagewebdev.com/raspberry-pi-getting-audio-working/
http://jeffskinnerbox.wordpress.com/2012/11/15/getting-audio-out-working-on-the-raspberry-pi/
http://alexpb.com/notes/articles/2012/11/14/error-when-playing-audio-on-raspbian-on-a-raspberry-pi/
http://elinux.org/R-Pi_Troubleshooting
