# Getting Started with ntios development.

## Introduction
This repository contains scripts and other tools used to create apps for Tibbo's [Ubuntu-based distribution](https://tibbo.com/store/tps/ltpp3g2/ubuntu.html) for the [Size 3 Linux Tibbo Project PCB (LTPP3), Gen. 2](https://tibbo.com/store/tps/ltpp3g2.html).

If you just want to download the latest version of our distribution in binary form to flash your device, [click here (direct download)](https://github.com/tibbotech/LTPP3_ROOTFS/releases/download/v0.6.0/ISPBOOOT.BIN).

## System Requirements 
* Windows / Linux 
  * Visual Studio Code
  * Docker Desktop (Windows) / Docker for Linux


## Getting Started
From From your terminal run the following command: 
```shell
docker pull tibbotech/ntios_dev_env:latest
docker run -it tibbotech/ntios_dev_env:latest /bin/bash
```


If you are using windows please use docker desktop. 

* Open VSCode 
* Use the extensions marketplace to install the docker extension.
  * ![Docker Extension](./docs/images/docker_extension.png)
* Make sure to "Install in Container" the C++ Extension Pack from Microsoft.
  * ![C++ Extension Pack](./docs/images/C_extension.png)
* Attach vscode to the container using the Docker extension. 
  * ![Select the container](./docs/images/vscode_container.png)
* Open the folder /root/ntios_dev_env
  * ![Open folder ](./docs/images/open_folder.png)
* Get the latest version of the ntios libraries by running the task: Get Libraries. 
  * ![Get Libraries Task ](./docs/images/get_libraries_task.png)
* Configure your device
  * Run the following 3 tasks. 
  * ![Configuration Tasks ](./docs/images/configuration_tasks.png)
* Configure the project
  * Run the CMAKE Configure task. 
  * Select the compiler kit
    * ![Select Kit](./docs/images/select_kit.png)


With you device confifured press F5. This will cause the device to begin debugging. 


Enjoy our building apps on your LTPP3(G2).