#!/bin/bash
#         Script: gcalclitts.sh
#        Contact: nonasuomy.github.io
#    Description: gcalcli + online google tts + offline pico2wave
#           Date: 20160411
#   Dependancies: [gcalcli] (python2 python2-dateutil python2-gflags python2-google-api-python-client python2-oauth2client1412 
#                 python2-parsedatetime python2-vobject) https://aur.archlinux.org/packages/gcalcli/
#                 svox-pico-bin [pico2wave] (popt sox (sox-dsd-git)) https://aur.archlinux.org/packages/svox-pico-bin/
#                 (Optional alternative tts engine) espeak (libpulse portaudio) https://www.archlinux.org/packages/community/x86_64/espeak/
#                 [mpg123] (alsa-lib libltdl (libtool) libpulse https://www.archlinux.org/packages/extra/x86_64/mpg123/
#                 vorbis-tools [ogg123] (curl flac libao libvorbis) https://www.archlinux.org/packages/extra/x86_64/vorbis-tools/
#                 sox [play] (file gsm lame libltdl (libtool) libpng libsndfile opencore-amr wavpack)
#                 (Optional if you don't want to use sox:play above.) alsa-utils [aplay] 
#                 iputils [ping] (libcap openssl sysfsutils) https://www.archlinux.org/packages/core/x86_64/iputils/	 

#Testing options for gcalcli: --nostarted (remove past events) --nocache --cache (use local or online) --refresh list/agenda (Force sync cache.)

# Settings:

# To get a list of calendars with your account type gcalcli list, 
# If you rencently added a calendar first type gcalcli list --refresh 
# and gcalcli agenda --refresh
calname="HQReminder"

# Checks to see if we have a WAN connection.
online=false
if [[ $(ping -q -c1 8.8.8.8 > /dev/null 2>&1; echo $?) -eq 0 ]]; then
  reminder=$(gcalcli --nocolor --calendar=$calname agenda $(date +%T) 11:59pm | grep -v 'No Events' | head -2 | tail -1 | grep -v '^$')
  online=true
else
  reminder=$(gcalcli --nocolor --cache --calendar=$calname agenda $(date +%T) 11:59pm | grep -v 'No Events' | head -2 | tail -1 | grep -v '^$')
  online=false
fi

# Check to see if we have events, if so remove 21 characters, date and whitespace from the start of the event.
if [[ $string != *"No Events"* ]]
then
  #echo "It's not there!";
  reminder=${reminder:21}
fi
# Debug
#echo $reminder

# Play a pre-notification sound (Some systems don't have the default sound files.)

# Sound files: https://cgit.freedesktop.org/sound-theme-freedesktop/tree/stereo
#/usr/bin/ogg123 -q /usr/share/sounds/freedesktop/stereo/dialog-information.oga

# Sound files: https://github.com/GNOME/gnome-control-center/tree/master/panels/sound/data/sounds
/usr/bin/ogg123 -q /usr/share/sounds/gnome/default/alert/glass.ogg

# Sound files: http://packages.ubuntu.com/source/trusty/all/ubuntu-touch-sounds
#/usr/bin/ogg123 -q /usr/share/sounds/ubuntu/notifications/Mallet.ogg

# If we are online then use google services, if not use local resources.
if [ $online == true ]; then
  # Change your 
  /usr/bin/mpg123 "http://translate.google.com/translate_tts?client=tw-ob&ie=UTF-8&tl=en&q=$reminder" > /dev/null 2>&1
else
  pico2wave -w tts.wav "$reminder"
  play tts.wav > /dev/null 2>&1

  # Alternative wav player.
  #aplay tts.wav > /dev/null 2>&1

  # Alternative tts.
  #echo "$reminder" | /usr/bin/espeak
fi
