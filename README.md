###### Cidana Test Platform

# Setup the Cidana Test Platform
### 1. Clone the project

```java
   cd ~
   git clone https://github.com/Cidana-Developers/CidanaTestPlatformRelease.git
```

### 2. Config 

```java
cd ./CidanaTestPlatformRelease/scripts && sudo chmod +x *
sudo ./config -c {xyz}     // Where `{xyz}` is a placeholder, please replace it with actual config name before executing
```

> NOTICE: config is only required for 1st time, you can skip to deploy step if the configuration is ready

### 3. Deploy

   after configuration finished, a deploy command will show up

```java
sudo ./launch.sh -c {HOMNE_DIR}/CidanaTestPlatformRelease/scripts/../confs/{xyz} -t ~/ctp -p 8083
```

   Please copy and run it to start the deploy process

> NOTICE: append option -u to deploy command will make the shell script to download newest docker images
