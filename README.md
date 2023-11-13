Riverside Provisioning
======================

Reproducible builds for `riverside`, a collection of utilities. Instead of spinning up a utility server and installing utilities on it, `riverside` runs containers for utilities that can be run locally or on a cloud VM.

Requirements
------------

* Docker
* Docker Compose

Best Practices
--------------

* To avoid bit rot, `docker save` our base images and back them up.Example: `docker save myimage:latest | gzip > myimage_latest.tar.gz`