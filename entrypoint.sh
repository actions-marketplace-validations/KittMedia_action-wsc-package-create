#!/bin/bash
# Build a valid WCF package

DO_COMPRESS=${2%/}
GIVEN_PACKAGE_NAME="${1%/}"

if [ -z $DO_COMPRESS ]; then
  DO_COMPRESS=true
fi

if [ -z "$GIVEN_PACKAGE_NAME" ]; then
  PACKAGE_NAME=${GITHUB_REPOSITORY#*/}
else
  PACKAGE_NAME=${GIVEN_PACKAGE_NAME}
fi

[ -z $PACKAGE_NAME ] && exit 1
cd $GITHUB_WORKSPACE
ls -l
test -e composer.json && echo -e "\nComposer installation\n-----------" && composer install
test -e acptemplate && echo -e "\nBuilding acptemplate.tar\n-------------------------" && cd acptemplate && tar cvf ../acptemplate.tar --exclude=.git* * && cd ..
test -e acptemplates && echo -e "\nBuilding acptemplates.tar\n-------------------------" && cd acptemplates && tar cvf ../acptemplates.tar --exclude=.git* * && cd ..
test -e file && echo -e "\nBuilding file.tar\n------------------" && cd file && tar cvf ../file.tar --exclude=.git* * && cd ..
test -e files && echo -e "\nBuilding files.tar\n------------------" && cd files && tar cvf ../files.tar --exclude=.git* * && cd ..
test -e files_preinstall && echo -e "\nBuilding files_preinstall.tar\n-----------------------------" && cd files_preinstall && tar cvf ../files_preinstall.tar --exclude=.git* * && cd ..
test -e files_wcf && echo -e "\nBuilding files_wcf.tar\n---------------------" && cd files_wcf && tar cvf ../files_wcf.tar --exclude=.git* * && cd ..
test -e template && echo -e "\nBuilding template.tar\n----------------------" && cd template && tar cvf ../template.tar --exclude=.git* * && cd ..
test -e templates && echo -e "\nBuilding templates.tar\n----------------------" && cd templates && tar cvf ../templates.tar --exclude=.git* * && cd ..

if [ -e "requirements" ]; then
  echo -e "\nBuilding requirements\n---------------------"
  cd requirements/
  
  for PACKAGE in *; do
    ./entrypoint.sh $PACKAGE false
  done
  
  cd ..
fi

if [ -e "optionals" ]; then
  echo -e "\nBuilding optionals\n------------------"
  cd optionals/
  
  for PACKAGE in *; do
    ./entrypoint.sh $PACKAGE false
  done
  
  cd ..
fi

if [ $DO_COMPRESS ]; then
  echo -e "\nBuilding $PACKAGE_NAME.tar.gz"
  echo -n "----------------"
  
  for i in `seq 1 ${#PACKAGE_NAME}`; do
      echo -n "-"
  done
  
  echo -en "\n"
  tar cvfz ${PACKAGE_NAME}.tar.gz --exclude=file --exclude=files --exclude=files_preinstall --exclude=files_wcf --exclude=acptemplate --exclude=acptemplates --exclude=template --exclude=templates --exclude=wcf-buildscripts --exclude=README* --exclude=CHANGELOG --exclude=LICENSE --exclude=.git* --exclude=composer* *
else
  echo -e "\nBuilding $PACKAGE_NAME.tar"
  echo -n "-------------"
  
  for i in `seq 1 ${#PACKAGE_NAME}`; do
      echo -n "-"
  done
  
  echo -en "\n"
  tar cvf ${PACKAGE_NAME}.tar --exclude=file --exclude=files --exclude=files_preinstall --exclude=files_wcf --exclude=acptemplate --exclude=acptemplates --exclude=template --exclude=templates --exclude=wcf-buildscripts --exclude=README* --exclude=CHANGELOG --exclude=LICENSE --exclude=.git* --exclude=composer* *
fi

exit 0
