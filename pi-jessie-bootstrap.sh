#!/bin/sh

# This script boot-straps a Raspberry Pi running a stock image of the Raspbian Jessie operating system on the SD card.
# This is invoked from a command prompt running this command:
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/wilsonmar/iot/master/pi-jessie-bootstrap.sh)"
# See https://wilsonmar.github.io/iot-raspberry-install/

start_time = time.time()

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

# Stop on error:
set -e

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
# sudo -v
# while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

fancy_echo "Is this the correct date and time?"
date
# By default the Raspberry is set to GB London because they were born in Cambriadge.
# Rather than manually running rpi-update or dpkg-reconfigure locales or tzdata:
# To avoid messages such as: Can't set locale; make sure $LC_* and $LANG are correct!
#     locale: Cannot set LC_CTYPE to default locale: No such file or directory
#     locale: Cannot set LC_ALL to default locale: No such file or directory

# Auto-edit "/etc/default/locale" file to 
# This doesn't work: update-locale LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# export LC_ALL=C
# locale-gen en_US.UTF-8
# Better to sudo nano ~/.bashrc and add the lines above, then restart bash.
# TODO: Set Keyboard to US English(US).
# TODO: Set Wi-Fi Country to US.

# Rather than manually running rpi-update or dpkg-reconfigure tzdata:
# sudo cp /usr/share/zoneinfo/UTC /etc/localtime
sudo cp /usr/share/zoneinfo/US/Mountain /etc/localtime

#fancy_echo "Exit for debugging."
#exit

python rpi-jessie/rpi-system-info.py
exit

fancy_echo "Disk space free on SD chip:"
  df -hT /home
fancy_echo "Disk space free on USB plug:"
  df -h /dev/sda1

#fancy_echo "List installed packages:"
#  dpkg -l | grep ii | less

# "Purging before updating to avoid updates of what will be purged:"
# Thanks to http://richardhayler.blogspot.com/2015/10/squeezing-raspbian-jessie-on-to-4gb-sd.html

if command -v wolfram-engine >/dev/null; then
  fancy_echo "Purging wolfram-engine client ..."
   sudo apt-get purge wolfram-engine -y
else
  fancy_echo "wolfram-engine already purged. Skipping."
fi

if command -v libreoffice >/dev/null; then
  fancy_echo "Purging libreoffice clients ..."
  sudo apt-get purge libreoffice*
  sudo apt-get purge libreoffice-base
  sudo apt-get purge libreoffice-impress
  sudo apt-get purge libreoffice-writer
  sudo apt-get purge libreoffice-calc
  sudo apt-get purge libreoffice-draw
  sudo apt-get purge libreoffice-math
  # After this operation, 256 MB disk space will be freed.
  # Do you want to continue? [Y/n] Y
else
  fancy_echo "libreoffice already purged. Skipping."
fi

# fancy_echo "Remove desktop photos ..."
#   rm -rf /usr/share/pixel-wallpaper

# ~/Desktop, Music, Photos, Videos are all blank.
fancy_echo "Remove python_games ..."
   rm -rf ~/python_games

#########

fancy_echo "UPDATING SYSTEM SOFTWARE – UPDATE:"
sudo apt-get update

fancy_echo "UPDATING SYSTEM SOFTWARE – UPGRADE:"
sudo apt-get upgrade -y

fancy_echo "UPDATING SYSTEM SOFTWARE – DISTRIBUTION:"
sudo apt-get dist-upgrade -y

fancy_echo "CLEANING:"
sudo apt-get clean

fancy_echo REMOVING orphaned dependencies:
sudo apt-get autoremove --purge -y


if ! command -v git >/dev/null; then
  fancy_echo "Installing Git client ..."
  sudo apt-get install git
  # (instead of git-all, which requires git-daemon-sysvinit)
else
  fancy_echo "Git already installed. Skipping."
fi


if ! command -v python-pip >/dev/null; then
  fancy_echo "Installing Python libraries needed by Ansible ..."
  sudo apt-get install python-pip
  # Ansible depends on python dev tools:
  sudo apt-get install python-dev -y
  # sshpass is a helper program for ssh:
  sudo apt-get install sshpass -y
  # Required by the paramiko library:
  sudo apt-get install libffi-dev libssl-dev -y
  # See http://docs.ansible.com/intro_installation.html
else
  fancy_echo "Python already installed. Skipping."
fi


# fancy_echo "Install Python modules Ansible requires:"
# Alternative A) easy_install was released in 2004 as part of setuptools - https://github.com/motdotla/ansible-pi
#sudo make install
#sudo easy_install jinja2 
#sudo easy_install pyyaml
#sudo easy_install paramiko
# Alternattive B) pip which came in 2008 to provide uninstall capabilities
# setuptools isn't part of Python 3 because pip is. pip can handle Wheels.
# Etc, see http://stackoverflow.com/questions/3220404/why-use-pip-over-easy-install?rq=1
if ! pip show paramiko >/dev/null; then
   pip install paramiko
else
  fancy_echo "pip paramiko already installed. Skipping."
fi

if ! pip show Jinja2 >/dev/null; then
   pip install Jinja2
   # See http://jinja.pocoo.org/docs/dev/intro/
else
  fancy_echo "pip Jinja2 already installed in pip. Skipping."
fi

if ! pip show PyYAML >/dev/null; then
   pip install PyYAML
else
  fancy_echo "pip PyYAML already installed. Skipping."
fi

if ! pip show httplib2 >/dev/null; then
   pip install httplib2
else
  fancy_echo "pip httplib2 already installed. Skipping."
fi

if ! pip show six >/dev/null; then
   pip install six
else
  fancy_echo "pip six already installed. Skipping."
fi



# [Install Ansible](http://docs.ansible.com/intro_installation.html).
if ! command -v ansible >/dev/null; then
  fancy_echo "Installing Ansible ..."
  sudo pip install ansible
  #sudo pip install ansible==1.5 # if a specific version is needed.
  #apt-get install ansible --ignore-installed --upgrade ansible
else
  fancy_echo "Ansible already installed. Skipping."
fi


if ! command -v usbmount >/dev/null; then
  fancy_echo "Installing usbmount ..."
  sudo apt-get install usbmount
else
  fancy_echo "usbmount already installed. Skipping."
fi


fancy_echo "Removing files ..."
cd ~
          SECRETS_FILEPATH="~/gits"
if [ -f ${SECRETS_FILEPATH} ]; then
   mkdir gits && cd gits
   pwd
fi
          SECRETS_FILEPATH="~/gits/wilsonmar"
if [ -f ${SECRETS_FILEPATH} ]; then
   mkdir wilsonmar && cd wilsonmar
fi
fancy_echo "Getting iot files from GitHub ..."
   pwd
   rm -rf iot
git clone https://github.com/wilsonmar/iot.git --depth=1
cd iot
cd rpi-jessie
pwd
python rpi-system-info.py
ls

# Run this from the same directory as this README file. 
fancy_echo "Running ansible playbook.yml ..."
#ansible-playbook playbook.yml -i hosts
# ansible-playbook playbook.yml -i hosts --ask-sudo-pass -vvvv --extra-vars "target=the_host_to_run_script_on"
#./playbook.yml
# The above installs git, vim, htop, ranger, mosh, 
#    automake, build-essential, ipython, node, npm, python-pip, ruby-dev, python-dev,
#   vim is a text editor compatible with the Vi UNIX editor - https://packages.debian.org/jessie/vim
#   mosh is a replacement for ssh that supports roaming intermittent connectivity - https://mosh.org/
#   cowsay to create ASCII art - https://packages.debian.org/jessie/cowsay
#   ranger is a console file visualizer and manager - https://packages.debian.org/jessie/ranger


#########

# TODO: Put these in Ansible:
if ! command -v mono >/dev/null; then
  fancy_echo "Installing Mono-complete 3.2.8+ ..."
  sudo apt-get install mono-complete -y
else
  fancy_echo "Mono already installed. Skipping."
fi

if ! command -v node >/dev/null; then
  fancy_echo "Installing Node v7.2.0+ ..."
  sudo curl -sL https://deb.nodesource.com/setup_7.x | bash -
  apt-get install -y nodejs
else
  fancy_echo "Node already installed. Skipping."
fi

####################

fancy_echo "Disk space free on SD chip:"
  df -hT /home
fancy_echo "Disk space free on USB plug:"
  df -hT /dev/sda1

fancy_echo "Verify versions installed:"
  date
  uname -a # Linux raspberrypi 4.4.32-v7+ #924 SMP Tue Nov 15 18:11:28 GMT 2016 armv7l GNU/Linux
  python --version # Python 2.7.9
  python3 --version # Python 3.4.2
  pip --version # pip 1.5.6 from /usr/lib/python2.7/dist-packages (python 2.7)
  ansible --version # ansible 2.2.0.0
  git --version # git version 2.1.4
  node --version # v7.2.0
  mono --version # Mono JIT compiler version 3.2.8 (Debian 3.2.8+dfsg-10)
#  vcgencmd measure_temp

elapsed_time = time.time() - start_time
fancy_echo "Elapsed time: $elapsed_time"

fancy_echo "sudo reboot # so changes take:"
# sudo reboot
# TODO: Press Y to confirm reboot or control+C to cancel.
