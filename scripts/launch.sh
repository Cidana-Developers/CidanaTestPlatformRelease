#!/bin/bash

echo "file name  :" $0;
echo "argu count :" $#;
echo "arguments  :" $*;

shell_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  # dir of shell script
echo "shell dir  :" ${shell_dir}

help=0;
if [ $# -eq 0 ]; then
    help=1;
elif [ "$1" != '-c' ]; then
    help=1;
elif [ "$1" == '-c' ]; then
    if [ $# -ne 4 ] && [ $# -ne 6 ] && [ $# -ne 5 ] && [ $# -ne 7 ]; then
        help=1;
    elif [ "$3" != '-t' ]; then
        help=1;
    fi
fi

# Color Setting for echo export
#    Black        0;30     Dark Gray     1;30
#    Red          0;31     Light Red     1;31
#    Green        0;32     Light Green   1;32
#    Brown/Orange 0;33     Yellow        1;33
#    Blue         0;34     Light Blue    1;34
#    Purple       0;35     Light Purple  1;35
#    Cyan         0;36     Light Cyan    1;36
#    Light Gray   0;37     White         1;37

if [ $help -eq 1 ]; then
    echo "*-----------------------------------------------------------------------------------------";
    echo "* launch.sh                                                                               ";
    echo "*     download docker image, setup running environment, and then launch the system        ";
    echo "*                                                                                         ";
    echo "* Usage: ./launch.sh [-opts] [args]                                                       ";
    echo "*                                                                                         ";
    echo "*     -h : print help                                                                     ";
    echo "*     -c : assign config root dir                                                         ";
    echo "*          [arg] config files root dir                                                    ";
    echo "*     -t : assign target dir                                                              ";
    echo "*          [arg] target dir to store the config fils and run-time data                    ";
    echo "*                target root dir MUST BE FULL-PATH, for example                           ";
    echo "*                $PWD                                                                     ";
    echo "*     -p : assign web service port                                                        ";
    echo "*          [arg] web service port, default to 80                                          ";
    echo "*                port reserved: 8080,9000                                                 ";
    echo "*                                                                                         ";
    echo "*     -u : force update docker image from docker hub                                      ";
    echo "*                                                                                         ";
    echo "* example                                                                                 ";
    echo "*     ./launch.sh -c ./cust1/ -t ~/tfs -p 8888 -u                                         ";
    echo "*-----------------------------------------------------------------------------------------";

    exit 0;
fi

echo -e "\033[1;33m Setup & Launch start ...\033[0m"


cfg_root_dir=$2
tar_root=$4
port=80
if [ $# -ge 5 ] && [ "$5" == '-p' ]; then
    port=$6
fi

dl_dockerimg=0
if [ $# -eq 5 ] && [ "$5" == '-u' ]; then
    dl_dockerimg=1
elif [ $# -eq 7 ] && [ "$7" == '-u' ]; then
    dl_dockerimg=1
fi

# echo "dl_dockerimg: "${dl_dockerimg}
if [ ${dl_dockerimg} -eq 1 ]; then
    update_docker="Download docker image from Docker Hub"
else
    update_docker="Use local image"
fi

echo -e "*------------------------------------------------------------------------------------------"
echo -e "* Input Arguments                                                                          "
echo -e "*     config root : \033[1;32m${cfg_root_dir}\033[0m                                       "
echo -e "*     target root : \033[1;32m${tar_root}\033[0m                                           "
echo -e "*     port        : \033[1;32m${port}\033[0m                                               "
echo -e "*     docker img  : \033[1;32m${update_docker}\033[0m                                      "
echo -e "*------------------------------------------------------------------------------------------"

# exit 0
step=1
#-----------------------------------------------------------------------------
#   Check config files
# 
cfg_files_ok=1
# echo "config root dir: ${cfg_root_dir}";
echo -e "\033[1;35m Step ${step}: Validating config root dir: ${cfg_root_dir} ...\033[0m"
((step += 1)) 
file=data_service_api/conf/app.conf
# echo "${file}"
if [ ! -f "${cfg_root_dir}/$file" ]; then
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[31m Not Found \033[0m]";
    cfg_files_ok=0;
else
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[32m OK \033[0m]";
fi

file=web_ui/www/apiCfg.php
if [ ! -f "${cfg_root_dir}/$file" ]; then
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[31m Not found \033[0m]";
    cfg_files_ok=0;
else
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[32m OK \033[0m]";
fi

file=web_ui/nginx/conf/nginx.conf
if [ ! -f "${cfg_root_dir}/$file" ]; then
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[31m Not found \033[0m]";
    cfg_files_ok=0;
else
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[32m OK \033[0m]";
fi

file=web_ui/nginx/conf.d/default.conf
if [ ! -f "${cfg_root_dir}/$file" ]; then
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[31m Not found \033[0m]";
    cfg_files_ok=0;
else
    echo -e "${cfg_root_dir}\033[1;37m/${file}\033[0m    --> [\033[32m OK \033[0m]";
fi

# Add here to check other config files

if [ $cfg_files_ok -ne 1 ]; then
    echo -e "\033[1;31mError: some config files missed !\033[0m -> exit(-1)";
    exit -1;
fi

#-----------------------------------------------------------------------------
#   Check target Root Dir
# 
echo -e "\033[1;35m Step ${step}: Check Target Root: ${tar_root} ...\033[0m";
((step += 1))

if [ -d "${tar_root}" ]; then
    msg=" delete \033[1;37m${tar_root}\033[0m   "
    rm -rf ${tar_root}
    if [ $? -ne 0 ]; then
        echo -e "${msg}--> [\033[31m Fail \033[0m]";
    else
        echo -e "${msg}--> [\033[32m OK \033[0m]";
    fi
fi

dir1=${tar_root}/data_service_api/conf
msg=" create \033[1;37m${dir1}\033[0m   "
mkdir -p ${dir1}
if [ $? -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail \033[0m]";
else
    echo -e "${msg}--> [\033[32m OK \033[0m]";
fi

dir1=${tar_root}/web_ui/www
msg=" create \033[1;37m${dir1}\033[0m   "
mkdir -p ${dir1}
if [ $? -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail \033[0m]";
else
    echo -e "${msg}--> [\033[32m OK \033[0m]";
fi

echo -e " Copy config files to \033[1;37m${tar_root}\033[0m ...";
# API service config file
file=app.conf
dir1=data_service_api/conf
msg="   file \033[1;37m${dir1}/${file}\033[0m   "
cp ${cfg_root_dir}/${dir1}/${file} ${tar_root}/${dir1}/${file}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail: ${res} \033[0m]";
    exit -2;
fi
echo -e "${msg}--> [\033[32m OK \033[0m]";

# web config file
file=apiCfg.php
dir1=web_ui/www
msg="   file \033[1;37m${dir1}/${file}\033[0m   "
cp ${cfg_root_dir}/${dir1}/${file} ${tar_root}/${dir1}/${file}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail: ${res} \033[0m]";
    exit -2;
fi
echo -e "${msg}--> [\033[32m OK \033[0m]";

# nginx config file
dir1=web_ui/nginx
msg="   dir  \033[1;37m${dir1}\033[0m   "
cp -r ${cfg_root_dir}/${dir1} ${tar_root}/${dir1}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail: ${res} \033[0m]";
    exit -2;
fi
echo -e "${msg}--> [\033[32m OK \033[0m]";

# exit 0;
if [ ${dl_dockerimg} -eq 1 ]; then
    #-----------------------------------------------------------------------------
    #   Download all docker images
    # 
    echo -e "\033[1;35m Step ${step}: Download docker images ...\033[0m";
    ((step += 1))

    # DB server
    echo -e "\033[0;36mdocker pull \033[1;36mmysql:5.7\033[0m ...";
    docker pull mysql:5.7
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download mysql:5.7\033[0m";
        exit -3;
    fi

    # DB initializer
    echo -e "\033[0;36mdocker pull \033[1;36mcidana/db_initializer\033[0m ..."
    docker pull cidana/db_initializer
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download db_initializer\033[0m";
        exit -3;
    fi

    # API service
    echo -e "\033[0;36mdocker pull \033[1;36mcidana/data_service\033[0m ..."
    docker pull cidana/data_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download data_service\033[0m";
        exit -3;
    fi

    # PHP web service
    echo -e "\033[0;36mdocker pull \033[1;36mcidana/php_web_service\033[0m ..."
    docker pull cidana/php_web_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download php_web_service\033[0m";
        exit -3;
    fi

    # Nginx web service
    echo -e "\033[0;36mdocker pull \033[1;36mcidana/nginx_web_service\033[0m ..."
    docker pull cidana/nginx_web_service
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download nginx_web_service\033[0m";
        exit -3;
    fi

    # AWCY service
    echo -e "\033[0;36mdocker pull \033[1;36mcidana/awcy\033[0m ..."
    docker pull cidana/awcy
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: failed to download awcy\033[0m";
        exit -3;
    fi
fi

x=1     # debug proposal
if [ ${x} == 1 ]; then
#-----------------------------------------------------------------------------
#   deploy awcy media files
# 
echo -e "\033[1;35m Step ${step}: Deploy awcy media files ...\033[0m";
((step += 1))

awcy_media_dir=${tar_root}/awcy/media/
# echo -e "\033[1;36mdeploy media files to ${awcy_media_dir} ...\033[0m"
msg="   target media dir \033[1;37m${awcy_media_dir}\033[0m   "
if [ ! -d ${awcy_media_dir} ]; then
    # echo -e "   \033[1;37m${awcy_media_dir}\033[0m   --> [\033[33m Not Exist \033[0m]";
    mkdir -p ${awcy_media_dir}
    res=$?
    if [ ${res} -ne 0 ]; then
        echo -e "${msg}--> [\033[31m Creat Fail \033[0m]";
        exit -2;
    fi
    echo -e "${msg}--> [\033[32m Creat Ok \033[0m]";
else
    echo -e "${msg}--> [\033[32m Exist \033[0m]";
fi

download_dir=${tar_root}/download
msg="   download dir \033[1;37m${download_dir}\033[0m   "
if [ ! -d ${download_dir} ]; then
    # echo "${download_dir} not exist, create ";
    mkdir -p ${download_dir}
    res=$?
    if [ ${res} -ne 0 ]; then
        echo -e "${msg}--> [\033[31m Creat Fail \033[0m]";
        exit -2;
    fi
    echo -e "${msg}--> [\033[32m Creat Ok \033[0m]";
else
    echo -e "${msg}--> [\033[32m Exist \033[0m]";
fi

media_path="ci_test_platform/awcy_media/"
echo -e "   download media files to \033[1;37m${download_dir}/${media_path}\033[0m ..."
ftp_cmd="wget -nH -r -c ftp://ftp.cidanash.com:8021/${media_path} --ftp-user=ci_test_platform --ftp-password=cidana"
(cd ${download_dir} && eval ${ftp_cmd})
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "   download media files      --> [\033[31m Fail: ${res} \033[0m]"
    exit -3;
fi
echo -e "   download media files      --> [\033[32m Ok \033[0m]"

# echo -e "   move media files to \033[1;37m${awcy_media_dir}\033[0m..."
# echo "${download_dir}/${media_path} ==> ${awcy_media_dir}"
msg="   move media files to \033[1;37m${awcy_media_dir}\033[0m      "
mv ${download_dir}/${media_path}/* ${awcy_media_dir}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg}--> [\033[31m Fail: ${res} \033[0m]"
    exit -3;
fi
echo -e "${msg}--> [\033[32m Ok \033[0m]"

#-----------------------------------------------------------------------------
#   deploy awcy mock data
# 
awcy_data_dir=${tar_root}/awcy/data/
echo -e "\033[1;36mdeploy mock data to ${awcy_data_dir} ...\033[0m"
if [ ! -d ${awcy_data_dir} ]; then
    echo "${awcy_data_dir} not exist, create ";
    mkdir -p ${awcy_data_dir}
fi

download_dir=${tar_root}/download
echo -e "\033[1;35m Step ${step}: Deploy awcy mock data ...\033[0m";
((step += 1))

if [ ! -d ${download_dir} ]; then
    echo "${download_dir} not exist, create ";
    mkdir -p ${download_dir}
fi

mock_src_path="ci_test_platform/awcy_mock_data/"
echo -e "\033[1;36m Download mock data to ${download_dir}/${mock_src_path} \033[0m"
ftp_cmd="wget -nH -r -c ftp://ftp.cidanash.com:8021/${mock_src_path} --ftp-user=ci_test_platform --ftp-password=cidana"
(cd ${download_dir} && eval ${ftp_cmd})
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[1;31mError: failed to download mock data from ftp\033[0m";
    exit -3;
fi

echo -e "\033[1;36m unzip mock data\033[0m"
unzip="tar zxf ${download_dir}/${mock_src_path}/awcy_demo_data.tar.gz"
# echo "========>" $unzip
(cd ${download_dir} && eval ${unzip})
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[1;31mError: failed to unzip the mock data\033[0m";
    exit -3;
fi

echo -e "\033[1;36m Move mock data \033[0m"
echo "${download_dir}/${media_path} ==> ${awcy_data_dir}"
cp -r ${download_dir}/awcy_demo_data/* ${awcy_data_dir}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "\033[1;31mError: failed to deploy media files\033[0m";
    exit -3;
fi


# echo "Remove the temp download dir ${download_dir}"
# rm -rf ${download_dir}

# exit 0;

#-----------------------------------------------------------------------------
#   deploy awcy cached source codes
# 
echo -e "\033[1;35m Step ${step}: Deploy awcy cache data ...\033[0m";
((step += 1))

# download
data_src_file="awcy.tar.gz"
data_src_path="ci_test_platform/awcy_data_src/"
echo -e "   download \033[1;37m${data_src_file}\033[0m to \033[1;37m${download_dir}/${data_src_path}\033[0m ..."
ftp_cmd="wget -nH -r -c ftp://ftp.cidanash.com:8021/${data_src_path} --ftp-user=ci_test_platform --ftp-password=cidana"
(cd ${download_dir} && eval ${ftp_cmd})
res=$?
msg="  download \033[1;37m${data_src_file}\033[0m      -->"
if [ ${res} -ne 0 ]; then
    echo -e "${msg} [\033[31m Fail: ${res} \033[0m]"
    exit -3;
fi
echo -e "${msg} [\033[32m Ok \033[0m]"

# deploy to target data source dir
awcy_cache=${download_dir}/${data_src_path}/${data_src_file}
# echo "awcy_cache: ${awcy_cache}"
msg="  awcy cache \033[1;37m${data_src_file}\033[0m   -->"
if [ -f ${awcy_cache} ]; then 
    echo -e "${msg} [\033[32m Found \033[0m]"
    cmd="tar zxf ${awcy_cache} -C ${tar_root}"

    echo -e "  ${cmd}";
    eval ${cmd}
    res=$?
    msg1="  deploy awcy cache \033[1;37m${data_src_file}\033[0m   -->"
    if [ ${res} -ne 0 ]; then
        echo -e "${msg1} [\033[31m Fail, err:${res} \033[0m]"
        exit -4
    fi
    echo -e "${msg1} [\033[32m OK \033[0m]"
else
    echo -e "${msg} [\033[31m Not Found \033[0m]"
fi

#-----------------------------------------------------------------------------
#   deploy jenkins_home
# 
echo -e "\033[1;35m Step ${step}: Deploy jenkins_home ...\033[0m";
((step += 1))

#  download
jks_home_file="jenkins_home.tar.gz"
jks_home_path="ci_test_platform/jenkins_home"
echo -e "   download \033[1;37m${jks_home_file}\033[0m to \033[1;37m${download_dir}/${jks_home_path}\033[0m ..."
ftp_cmd="wget -nH -r -c ftp://ftp.cidanash.com:8021/${jks_home_path} --ftp-user=ci_test_platform --ftp-password=cidana"
(cd ${download_dir} && eval ${ftp_cmd})
res=$?
msg="  download \033[1;37m${jks_home_file}\033[0m      -->"
if [ ${res} -ne 0 ]; then
    echo -e "${msg} [\033[31m Fail: ${res} \033[0m]"
    exit -3;
fi
echo -e "${msg} [\033[32m Ok \033[0m]"

deploy_target="${tar_root}/jenkins"
msg="  deploy target dir \033[1;37m${deploy_target}\033[0m      "
if [ ! -d ${deploy_target} ]; then
    mkdir -p ${deploy_target}
    res=$?
    if [ ${res} -ne 0 ]; then
        echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
        exit -3;
    fi
    echo -e "${msg} --> [\033[32m Created \033[0m]"
else
    echo -e "${msg} --> [\033[32m Found \033[0m]"
fi

# deploy jenkins_home to target dir
jks_home_tmp=${download_dir}/${jks_home_path}/${jks_home_file}
# echo "jks_home_tmp: ${jks_home_tmp}"
msg="  jenkins_home \033[1;37m${jks_home_file}\033[0m   -->"
if [ -f ${jks_home_tmp} ]; then 
    echo -e "${msg} [\033[32m Found \033[0m]"
    cmd="tar zxf ${jks_home_tmp} -C ${deploy_target}"

    echo -e "  ${cmd}";
    eval ${cmd}
    res=$?
    msg1="  deploy jenkins_home \033[1;37m${jks_home_file}\033[0m   -->"
    if [ ${res} -ne 0 ]; then
        echo -e "${msg1} [\033[31m Fail, err:${res} \033[0m]"
        exit -4
    fi
    echo -e "${msg1} [\033[32m OK \033[0m]"
else
    echo -e "${msg} [\033[31m Not Found \033[0m]"
    exit -5
fi

# exit 0

#-----------------------------------------------------------------------------
# echo "remove the temp download dir ${download_dir}"
msg=" delete temp download dir \033[1;37m${download_dir}\033[0m      --> "
rm -rf ${download_dir}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} [\033[31m Fail: ${res} \033[0m]"
    exit -3;
fi
echo -e "${msg} [\033[32m Ok \033[0m]"

# exit 0;

#-----------------------------------------------------------------------------
#   Launch dock containers
# 
echo -e "\033[1;35m Step ${step}: Launch docker containers ...\033[0m";
((step += 1))

#   Database Server
docker stop dbserver
echo -e "\033[0;36m Launch & Initialize \033[1;36mDatabase server\033[0m ..."
cmd="docker run --rm --name dbserver -v ${tar_root}/db:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=dbserver@cidana -d mysql:5.7 && docker run --rm --name dbinitializer --link dbserver:dbserver -e MYSQL_ROOT_PASSWORD=dbserver@cidana cidana/db_initializer"

echo "  ${cmd}";

if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mDatabase server\033[0m     "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"

#   API Service
docker stop app_server
echo -e "\033[0;36m Launch \033[1;36mAPI Service\033[0m ..."
cmd="docker run -t --name app_server --rm --link dbserver:dbserver -p 8080:8080 -v ${tar_root}/data_service_api/conf/app.conf:/bin/data_service/conf/app.conf -v ${tar_root}/data_service_api/logs:/bin/data_service/logs -d cidana/data_service"
echo "${cmd}";

if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mAPI Service\033[0m     "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"

#   PHP Web Service
docker stop php-web

echo -e "\033[0;36m Launch \033[1;36mPHP Web Service\033[0m ..."
cmd="docker run --rm --name php-web -p 9000:9000 --link app_server:app_server -v ${tar_root}/web_ui/www/apiCfg.php:/usr/share/nginx/html/apiCfg.php:ro -d cidana/php_web_service"
echo "${cmd}";

if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mPHP Web Service\033[0m     "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"

#   Nginx Web Service
docker stop nginx-server

echo -e "\033[0;36m Launch \033[1;36mNginx Web Service\033[0m ..."
cmd="docker run --rm --name nginx-server -p ${port}:80 --link php-web:phpfpm -v ${tar_root}/web_ui/www/apiCfg.php:/usr/share/nginx/html/apiCfg.php:ro -v ${tar_root}/web_ui/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro -v ${tar_root}/web_ui/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro -v ${tar_root}/web_ui/nginx/logs:/var/log/nginx -d cidana/nginx_web_service"
echo "${cmd}";

if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mNginx Web Service\033[0m     "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"

# -----------------------------------------------------------------------------------
#       AWCY service
# 
docker stop awcy_server

echo -e "\033[0;36m Launch \033[1;36mAWCY Service\033[0m ..."
cmd="docker run --rm --name awcy_server -p 3000:3000 -v ${tar_root}/awcy/data:/data -v ${tar_root}/awcy/media:/media --env MEDIAS_SRC_DIR=/media --env AWCY_API_KEY=cidana --env LOCAL_WORKER_ENABLED=true --env LOCAL_WORKER_SLOTS=4 -d cidana/awcy"

echo "${cmd}";

if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mAWCY Service\033[0m     "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"

fi  # if [ ${x} == 1 ]; then

#=====================================================================================
# 
#       Jenkins service & accompanist web service
# 
#  Jenkins service
echo -e "\033[36m Launch \033[1;36mJenkins Service\033[0m ..."
cmd="docker run --rm --name jenkins --privileged=true -p 8082:8080 -p 50000:50000 -v ${tar_root}/jenkins/jenkins_home:/var/jenkins_home -v ${tar_root}/jenkins/jenkins-web/www:/var/tmp -d cidana/jenkins:deploy"
echo "${cmd}";

docker stop jenkins
if [ $? -eq 0 ]; then
    sleep 2s
fi

msg="  \033[1;37mJenkins service\033[0m      "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]"
    exit -4
fi
echo -e "${msg} --> [\033[32m Ok \033[0m]"


# --- additional Jenkins-web service ---
echo -e "\033[36m Deploy \033[1;36m additional Jenkins Web Service configurations\033[0m ..."

# deploy nginx config files
nginx_cfg_home=${shell_dir}/../3rd-party/jenkins-web/nginx
nginx_cfg_file="conf/nginx.conf"
nginx_cfg="${nginx_cfg_home}/${nginx_cfg_file}"
msg="  ${nginx_cfg_home}/\033[1;37m${nginx_cfg_file}\033[0m   "
if [ ! -f ${nginx_cfg} ]; then
    echo -e "${msg} --> [\033[31m Not found \033[0m]"
    exit -2
fi
echo -e "${msg} --> [\033[32m found \033[0m]"

nginx_cfg_file="conf.d/default.conf"
nginx_cfg="${nginx_cfg_home}/${nginx_cfg_file}"
msg="  ${nginx_cfg_home}/\033[1;37m${nginx_cfg_file}\033[0m   "
if [ ! -f ${nginx_cfg} ]; then
    echo -e "${msg} --> [\033[31m Not found \033[0m]"
    exit -2
fi
echo -e "${msg} --> [\033[32m found \033[0m]"

jks_web="jenkins-web"
tar_dir="${tar_root}/jenkins" #${jks_web}/"
if [ ! -d ${tar_dir} ]; then
    mkdir -p ${tar_dir}
    err=$?
    msg="  create \033[1;37m${tar_dir}\033[0m    "
    if [ ${err} -ne 0 ]; then
        echo -e "${msg} --> [\033[31m Fail: ${err} \033[0m]";
        exit -2
    fi
    echo -e "${msg} --> [\033[32m OK \033[0m]";
else
    echo -e "  \033[1;37m${tar_dir}\033[0m    --> [\033[32m Found \033[0m]";
fi

msg="  copy dir ${shell_dir}/../\033[1;37m3rd-party/${jks_web}/\033[0m to \033[1;37m ${tar_root}/jenkins/${jks_web}/\033[0m   "
cp -r ${shell_dir}/../3rd-party/${jks_web} ${tar_dir}
err=$?
if [ ${err} -ne 0 ]; then
    echo -e "${msg} --> [\033[1;31m Fail: ${err} \033[0m]";
    exit -2
fi
echo -e "${msg} --> [\033[1;32m Ok \033[0m]";

# -- jenkins php service --
docker stop jks-php
if [ $? -eq 0 ]; then
    sleep 2s
fi
echo -e "\033[0;36m Launch \033[1;36mJenkins Php Service\033[0m ..."

tar_dir="${tar_root}/jenkins/${jks_web}/"
cmd="docker run --rm --name jks-php -p 9001:9000 -v ${tar_dir}/www:/usr/share/nginx/html:ro -d php:5.6-fpm"
echo -e "${cmd}";

msg=" \033[1;37m Jenkins Php Service \033[0m   "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[31m Fail: ${res} \033[0m]";
    exit -4
fi
echo -e "${msg} --> [\033[32m OK \033[0m]";

# jenkins Nginx service
docker stop jks-nginx
if [ $? -eq 0 ]; then
    sleep 2s
fi
echo -e "\033[0;36m Launch \033[1;36mJenkins Nginx Service\033[0m ..."

cmd="docker run --rm --name jks-nginx -p 8084:80 --link jks-php:phpfpm-jks -v ${tar_dir}/www:/usr/share/nginx/html:ro -v ${tar_dir}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf:ro -v ${tar_dir}/nginx/conf.d/default.conf:/etc/nginx/conf.d/default.conf:ro -v ${tar_dir}/nginx/logs:/var/log/nginx -d nginx:1.17"
echo -e "${cmd}";

msg=" \033[1;37m Jenkins Nginx Service \033[0m   "
eval ${cmd}
res=$?
if [ ${res} -ne 0 ]; then
    echo -e "${msg} --> [\033[1;31m Fail: ${res} \033[0m]";
    exit -4
fi
echo -e "${msg} --> [\033[32m OK \033[0m]";

chmod -R 777 ${deploy_target}

#=====================================================================================
# 
#       Finish
# 
echo -e "\n \033[42;30m --- Setup & Launch finish successfuly ! --- \033[0m"

cfgfile=${tar_root}/data_service_api/conf/app.conf
web_home=`cat ${cfgfile} | grep "web_site" | cut -d"\"" -f2`
# echo "web_home: ${web_home}"

if [ -n "${web_home}" ]; then
    echo -e "-----------------------------------------------------------------------------"
    echo -e "\n Now, you can access the CTP system via \033[1;35m ${web_home} \033[0m\n"
    echo -e " Please copy above CTP entrance URL and open it in any browser\n"
    echo -e " [default account] user: guest01, password: 123\n"
    echo -e " Enjoy!"
    echo -e "-----------------------------------------------------------------------------"
fi


exit 0
