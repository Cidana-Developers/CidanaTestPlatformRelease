###### Cidana Test Platform

# Deploy CTP

##### - CTP
`CTP` (Cidana Test Platform) is a test system to test and measure your video dec/enc quality from multi-dimensions, it include but not limited coverage, conformance, performance, regression

##### - CTPR
`CTPR` is `CTP` release package

This document will guide you to deploy the `CTP` in your test machine, step by step

### Environment

Before actual deploy, please make sure your test machine meets our requirements 

#### - OS
  `CTP` runs on `Linux` platform, like Ubuntu, CentOS. It could be deployed either in `real linux machine` or `virtual linux machine`
  * Ubuntu 16.04 or above (Recommend)
  * CentOS 8.1 or above

#### - Git
  Git 2.7 or above

   `Git` is a popular and convenience tool to fetch source code or other resource, with this tool you can get `CTPR` easily from `Github`. But this is not mandatory, you can get the `CTPR` in other way, for example download `CTPR` zip package, copy it to `target machine` and then unzip it. As you see, it's much complex than `Git`, that's why we recommend `Git` for `CTPR` retrieving

  the folloving command can check if the `Git` is ready in your test machine
   ```shell
      git --version
   ```
   if `git` is ready, you will get exact version number, like `git version 2.7.4`, else error `command not found` will occurs. 
   
   please install `git` by command if necessary

   ```shell
      sudo apt install git
   ```

#### - Docker

   Docker 19.0 or above

   Please use the following command to check if the test machine have docker installed

   ```shell
      docker --version
   ```
   if error `command not found` occurs, which means no docker env install in test machine, please install it first

   * install docker in Ubuntu
   ```shell
      sudo apt install docker.io
   ```

   * install docker in CentOS

   please refer to https://docs.docker.com/engine/install/centos/#install-using-the-repository to install docker in CentOS

### Get CTPR package

##### 1. Login

   First of all, you should login the test machine by any `ssh client`, like `putty`, `xman`.
   Once login success, you will enter your `personal home dir`, which should be `/home/{xxxx}` where `{xxx}` is your login name

##### 2. Target dir

   In theory, `CTP` could be deployed to any place, but for permission consideration, we recommand use your `personal home dir` as the `target deploy dir`.

   By default, the current dir after login is your `personal home dir`, so you don't need to do anything, but if you are not in `personal home dir`, you can use command `cd` or `cd ~` go back to your `personal home dir`


##### 3. Get CTP from Github

```shell
   git clone https://github.com/Cidana-Developers/CidanaTestPlatformRelease.git
```

### Config (optional)

   Before deploy, we need to generate the deploy configuration, we offer a utility to help you to make the configuration easily

```shell
   cd ./CidanaTestPlatformRelease/scripts && sudo chmod +x *.sh && sudo ./config.sh -c {xyz}     
```

   * Where `{xyz}` is a placeholder, please replace it with `real config name`
   * Config is only required in 1st time deploy, if you try to deploy again it could be skipped since the configuration is ready

   Follow instructions, set the correct `IP`/`domain` & `port` of `target machine`

   After configuration finish successfully, a suggestion `deploy CLI` will show up

```shell
   sudo ./launch.sh -c {HOMNE_DIR}/CidanaTestPlatformRelease/scripts/../confs/{xyz} -t ~/ctp -p 8083 -u
```
   * above `CLI` is just a example in my test machine, please do not copy it directly, instead copy the `CLI` show on your machine

### Deploy

   Please copy the `CLI` shows in config step, and run it to start the deploy process, wait until deploy process finish

   * option `-u` in `deploy CLI` tail will force download the newest docker images during deploy period, else we will preferred the local docker images and only download docker images not exist in local

Once deploy finish successfully, the CTP system `entrance` will display, for example

```java
   http://192.168.0.88:8083
```

   Please copy above `entrance URL` and open it in any browser, if login page show up, that means whole `CTP` deploy operation finished and successfully

   evaluation account is shown as below

   ```java
      user: guest01, password: 123
   ```

   Enjoy!