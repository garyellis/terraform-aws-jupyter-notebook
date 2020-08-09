#!/bin/bash

TERRAFORM_VERSION=0.12.29
TERRAGRUNT_VERSION=v0.23.33
TFLINT_VERSION=v0.18.0

TERRAGRUNT_DOWNLOAD_URL=https://github.com/gruntwork-io/terragrunt/releases/download/$TERRAGRUNT_VERSION/terragrunt_linux_amd64
TFENV_REPO_URL=https://github.com/tfutils/tfenv.git
TFENV_REMOTE=https://releases.hashicorp.com
TFLINT_DOWNLOAD_URL=https://github.com/terraform-linters/tflint/releases/download/$TFLINT_VERSION/tflint_linux_amd64.zip


function tfenv(){
  if [ ! $(find ~/.tfenv -name tfenv) ]; then
    git clone $TFENV_REPO_URL ~/.tfenv
  fi
  if ! grep -q 'PATH=.*tfenv/bin:' ~/.bash_profile ; then
    echo 'export PATH=$HOME/.tfenv/bin:$PATH' >> ~/.bash_profile
  fi
  if ! grep -q TERRAFORM_RELEASES_URL ~/.bash_profile ; then
    echo "export TFENV_REMOTE=$TFENV_REMOTE" >> ~/.bash_profile
  fi

  ~/.tfenv/bin/tfenv install $TERRAFORM_VERSION
  ~/.tfenv/bin/tfenv use $TERRAFORM_VERSION
}

function terragrunt(){
  mkdir -p ./bin
  curl -L -o ./bin/terragrunt $TERRAGRUNT_DOWNLOAD_URL
  chmod 755 ./bin/terragrunt
}

function terraform_plugins(){
    mkdir -p $1
    while read plugin; do
        filename=$(basename $plugin)
        curl -RO $plugin
        unzip -o $filename -d $1
        rm -f $filename
    done < $2
}

function tflint(){
  mkdir -p ./bin
  filename=$(basename $TFLINT_DOWNLOAD_URL)
  curl -L -RO $TFLINT_DOWNLOAD_URL
  unzip -o $filename -d ./bin
  chmod 755 ./bin/tflint
  rm -f $filename
}

function terraform_clean(){
  ( cd $1 && rm -f *.tfstate* ; rm -fr .terraform )
}


eval $@
