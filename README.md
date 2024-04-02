<div align="center"><h1>Rofi</h1>
<p align="center">A collection of <a href="https://github.com/davatorium/rofi">Rofi</a> based custom <i>Launcher</i>, <i>Powermenu</i> & <i>Applets</i>.</p>

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

- Then, Clone this repository and follow indications in the [notes](#Notes) section
```
$ git clone https://github.com/mdfk15/Rofi.git
```

### Showcase

![img](preview/widgets.gif)

<details>
<summary><b>Wifi</b></summary>

|Main menu|
|--|
|![img](preview/wireless/main.png)|

|List menu|
|--|
|![img](preview/wireless/list.png)|

|Password|
|--|
|![img](preview/wireless/confirm.png)|

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
<summary><b>Battery, Volume</b></summary>

|Battery|Volume|
|--|--|
|![img](preview/battery.png)|![img](preview/volume.png)|


</details>

<details>
<summary><b>Screenshot, Powermenu & Calendar</b></summary>

|Screenshot|Powermenu|Calendar|
|--|--|--|
|![img](preview/screenshot.png)|![img](preview/powermenu.png)|![img](preview/calendar/main.png)|

</details>

<summary><b>Launcher</b></summary>

Then, execute launcher: ```$ rofi -show drun -theme /path/to/rasi/launcher.rasi```
|Launcher|
|--|
|![img](preview/launcher.png)

## Notes
- There's no install script, because I'd suggest using these files as templates rather than directly copying them (simply because they weren't designed to be cross-platform). If you would like to use these files, you can try doing the following manually:
    - install `/rasi/` to `~/.config/rofi`
    - install `/scripts/` to `~/.config/scripts/`
    - install `/icons/` to `~/.icons/`
- To run widgets you can execute the corresponding script.
    - ```sh <path-to-script>```
    - Also you can check my [dotfiles](https://github.com/mdfk15/dotfiles) for an implementation example on Qtile DE to inspire your own configuration.
- These widget are inspired by [@adi1090](https://github.com/adi1090x/rofi).
