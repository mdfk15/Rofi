<div align="center"><h1>Rofi</h1>
<p align="center">A collection of <a href="https://github.com/davatorium/rofi">Rofi</a> based custom <i>Applets</i>, <i>Launchers</i> & <i>Powermenus</i>.</p>

![img](preview/main-preview.png)

## What is Rofi?

[Rofi](https://github.com/DaveDavenport/rofi) is A window switcher, Application launcher and dmenu replacement. Rofi started as a clone of simpleswitcher and It has been extended with extra features, like an application launcher and ssh-launcher, and can act as a drop-in dmenu replacement, making it a very versatile tool. Rofi, like dmenu, will provide the user with a textual list of options where one or more can be selected. This can either be running an application, selecting a window, or options provided by an external script.
</div>
## Installation

> **Everything here is created on rofi version : `1.7.5`**
* First, Make sure you have the same (stable) version of rofi installed.
  - On Arch / Arch-based : **`sudo pacman -S rofi`**
  - On Debian / Ubuntu : **`sudo apt-get install rofi`**
  - On Fedora : **`sudo dnf install rofi`**

- Then, Clone this repository -
```
$ git clone https://github.com/mdfk15/Rofi.git
```

### Previews Widgets

![img](preview/widgets.gif)

<details>
<summary><b>Wifi</b></summary>

|Main menu|List menu|Confirm|
|--|--|--|
|![img](preview/wireless/main.png)|![img](preview/wireless/list.png)|![img](preview/wireless/confirm.png)

</details>

<details>
<summary><b>Bluetooth</b></summary>

|Main menu|List menu|
|--|--|
|![img](preview/bluetooth/main.png)|![img](preview/bluetooth/list.png)

</details>

<details>
<summary><b>Musictl</b></summary>

|Main menu|List menu|
|--|--|
|![img](preview/musictl/main.png)|![img](preview/musictl/list.png)

</details>

<details>
<summary><b>Battery, Volume & Screenshot</b></summary>

|Battery|Volume|Screenshot
|--|--|--|
|![img](preview/battery.png)|![img](preview/volume.png)|![img](preview/screenshot.png)


</details>

<details>
<summary><b>Calendar</b></summary>

|Main menu|List menu|
|--|--|
|![img](preview/calendar/main.png)|![img](preview/calendar/list.png)

</details>

<summary><b>Power menu & Launcher</b></summary>

|Powermenu|
|--|
|![img](preview/powermenu.png)

Then, execute launcher: ```$ rofi -show drun -theme /path/to/rasi/launcher.rasi```
|Launcher|
|--|
|![img](preview/launcher.png)

## Notes
- There's no install script, because I'd suggest using these files as templates rather than directly copying them (simply because they weren't designed to be cross-platform). If you would like to use these files, you can try doing the following manually:
    - install `/rasi/` to `$CONFIG/rasi`
    - install `/scripts/` to `~/.config/scripts/`
    - install `/icons/` to `~/.icons/`
- Also you can check my [dotfiles](https://github.com/mdfk15/dotfiles)
