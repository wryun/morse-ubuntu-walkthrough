*WARNING: these scripts were made for a demo, are NOT an official
release, and were originally intended to be used in a
presentation/workshop. They are provided as is.*

Walkthough of building/running Morse drivers on Ubuntu 22.04
------------------------------------------------------------

These are NOT intended to be generic bring-up scripts, just an example
of how to quickly follow the
(Linux porting guide)[https://www.morsemicro.com/resources/appnotes/MM_APPNOTE-24_Linux_Porting_Guide.pdf].

Using `ubuntu_22_vm.sh` beforehand is optional. This will start an Ubuntu 22.04 VM and pass through
a Morse USB device. If you use this, you can access it via ssh like this:

    ssh ubuntu@localhost -p 2222

It will also mirror the current directory into the VM at `~/hostdir`.

This VM is a great place to run these scripts, but do NOT run them directly
in hostdir, as this is mounted via 9p. i.e. do:

    ./hostdir/02_requirements.sh
