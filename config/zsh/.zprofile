# . $HOME/.bashrc
if [ "$(tty)" = "/dev/tty1" ]; then
    /usr/bin/ssh-agent /usr/bin/startx
    logout
fi
