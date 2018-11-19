{ mutate, bash, coreutils, libnotify, scrot, xclip, openssh, utillinux }:
mutate ./screenshot.sh {
       inherit bash coreutils scrot libnotify xclip openssh utillinux;
}
