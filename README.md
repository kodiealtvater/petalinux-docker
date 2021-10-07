# Instructions for using this Dockerfile/Dockerimage

Building the Dockerfile can be done by running this  
```docker build --build-arg PETA_VERSION=2020.2 --build-arg PETA_RUN_FILE=petalinux-v2020.2-final-installer.run -t petalinux:2020.2 .```

# Running the Petalinux docker image and being able to use a GUI is done like this.  
- Copy your ~/.Xauthority to a writeable drive.  
- Run the command below!  
```docker run -it -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=$DISPLAY -h $HOSTNAME -v <PATH TO COPIED XAUTHORITY>/.Xauthority:/home/vivado/.Xauthority -v <PATH TO WHERE YOU WANT TO CLONE REPO>:/home/vivado/project petalinux:2020.2```
