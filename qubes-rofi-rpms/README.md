# qubes-rofi-rpms

A set of [rofi](https://github.com/davatorium/rofi) RPMs for [Qubes OS](https://www.qubes-os.org/) dom0.

## Installation

* Clone repo to one of your VMs (`untrusted` in this example)
    ```
    [user@untrusted ~]$ git clone https://github.com/ajgon/qubes-rofi-rpms
    ```

* Copy necessary files to your dom0 (at least `rofi-themes` and `rofi` are required`)
    ```
    [me@dom0]$ qvm-run --pass-io untrusted 'cat /home/user/qubes-rofi-rpms/dist/rofi-1.5.4-1.qbs4.0.x86_64.rpm' > /tmp/rofi-1.5.4-1.qbs4.0.x86_64.rpm
    [me@dom0]$ qvm-run --pass-io untrusted 'cat /home/user/qubes-rofi-rpms/dist/rofi-themes-1.5.4-1.qbs4.0.noarch.rpm' > /tmp/rofi-themes-1.5.4-1.qbs4.0.noarch.rpm
    ```

* Install packages

    ```
    [me@dom0]# dnf install /tmp/rofi-1.5.4-1.qbs4.0.x76_64.rpm /tmp/rofi-themes-1.5.4-1.qbs4.0.noarch.rpm
    ```

* Enjoy rofi in dom0!

## Security and privacy

Please, follow the Qubes OS principles, and verify those packages before installing. Do not trust blindly, that they're safe.
For `rofi-extras` I used [this package](https://download-ib01.fedoraproject.org/pub/fedora-secondary/updates/30/Everything/i386/Packages/r/rofi-themes-1.5.4-1.fc30.noarch.rpm) as a base (just switched release to qbs4.0).
For remaining packages, I built them basing on the files in `src` repository.
