TextBlade Dongler
===

![TB and CSR8510 dongle](doc/TB%20and%20CSR8510%20dongle.jpg)

The [Waytools TextBlade](http://waytools.com) is amazing but not every computer has Bluetooth 4.0. With a [cheap USB dongle based on the CSR8510 chipset](https://www.google.com/search?q=buy%20csr8510) you can make a wireless USB keyboard. The dongle needs to be paired to the TextBlade and then you can plug it in anywhere and it will appear as a USB keyboard.

This project aims to make that easy.

Roadmap
---
* [x] Working NixOS VM with Bluetooth
* [x] Make working dongle
* [x] Nix package to compile program to switch dongle back into BT host mode
* [ ] Scripts to automate
  * [x] Automatic pairing and writing
  * [ ] Fix TODOs in the scripts
  * [ ] Autostart on VM terminal, no SSH needed to write the pairing
* [ ] LiveCD/USB image

Set up test VM
---
1. Install Nix and VirtualBox
  * http://nixos.org/nix
  * http://virtualbox.org
1. Install NixOps
  * `nix-env -i nixops`
1. Deploy dongler VM
  * `nixops create -d dongler dongler-vm/*.nix`
  * `nixops deploy --force-reboot -d dongler`
1. Shut down VM and enable USB in VirtualBox settings
1. Start VM and attach USB dongle to VM
1. Log in and play with Bluez 5
  * `nixops ssh -d dongler dongler`
  * You should be able to pair with `pair.sh`, it will automatically pair with the first thing it finds
  * Once paired, you can use `make-hid.sh <TextBlade address>` to write the pairing to the dongle
  * Verify the written keys with `bccmd psread`
  * For manual control, pair with `bluetoothctl`
    * `scan on`
    * `devices`
    * `pair <tab>`
    * `quit`
  * If you have a CSR dongle that is already in HID mode, you can switch it to bluetooth mode with `hid2hci`

Available data
---
Once the device is paired, the `/var/lib/<dongle mac>/<TB mac>/info` file contains all the pairing information. This is used by `make-hid.sh` to write correct token into the CSR dongle.

CRS8510 programming
---
The `PSKEY_USR42` field has to be set to `tbMac + 1482 + be16(EDiv) + be64(Rand) + be16(Key)` (all hexadecimal), where be16 and be64 are big-endian representations, 2 and 8 bytes long respectively. This means the Rand is reversed entirely and the Key on every 2 bytes

Once that is set, `bccmd psset -r -s 0 0x3cd 2` will set the dongle into USB keyboard mode. `make-hid.sh` does that for you.
