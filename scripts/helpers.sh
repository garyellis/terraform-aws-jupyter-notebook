#!/bin/bash

# helpers config
VERSION_FILE=${VERSION_FILE:-Makefile}
_VERSION_VARIABLE_MATCH='^VERSION=v[0-9]+[.][0-9]+[.][0-9]+$'
VERSION_VARIABLE_MATCH=${VERSION_VARIABLE_MATCH:-${_VERSION_VARIABLE_MATCH}}
_VERSION_VARIABLE_MATCH_SED='\(^VERSION=\)v\([0-9]\+\.[0-9]\+\.[0-9]\+$\)'
VERSION_VARIABLE_MATCH_SED=${VERSION_VARIABLE_MATCH_SED:-${_VERSION_VARIABLE_MATCH_SED}}

# source the project config when it exists
[ -e "./scripts/config.sh" ] && source ./scripts/config.sh
# source the user project config when it exists
[ -e "~/config.sh" ] && source ~/config.sh

function git_tag(){
  repo=$1
  version=$2
  release_branch=$3
  branch=$4

  remote=release

  if [ "$branch" == "$release_branch" ]; then
    echo "==> release branch detected. creating tag"
    git remote add $remote $repo
    # create a lightweight tag only
    git tag -a $version -m "release: ${version}"
    git push $remote --tags
    git remote remove $remote
  else
    echo "==> $branch is not the release branch. skip tag creation"
  fi
}

function tag_exists(){
  git fetch --tags
  if grep -q "^$1$" <<<"$(git tag)"; then
    return 0
  else
    return 1
  fi
}

function get_version(){
  version=$(awk -v version_var="$VERSION_VARIABLE_MATCH" -F'=' '$0~version_var {print $2}' $VERSION_FILE)
  echo $version
}

function increment_version(){
  _version=$(get_version ${VERSION_VARIABLE_MATCH}| sed 's/^v//')
  version=( ${_version//./ } )

  echo "==> current -> major: ${version[0]} minor: ${version[1]} patch: ${version[2]}"

  case "$1" in
    major)
      (( version[0] ++ ))
      version[1]=0
      version[2]=0
      ;;
    minor)
      (( version[1] ++ ))
      version[2]=0
      ;;
    patch)
      (( version[2] ++ ))
      ;;
    *)
      echo "$1 is not a valid input"
      return 1
      ;;
  esac
  new_version=v$(printf "%s." ${version[0]} ${version[1]} ${version[2]})
  new_version=${new_version%?}


  echo "==> new -> major: ${version[0]} minor: ${version[1]} patch: ${version[2]}"
  echo "==> new version -> $new_version"
  sed -i "s/$VERSION_VARIABLE_MATCH_SED/\1${new_version}/" $VERSION_FILE
  git add $VERSION_FILE
}

function pre_commit(){
  version=$(get_version ${VERSION_VARIABLE_MATCH})
  if tag_exists $version; then
    echo "==> the tag for version $version already exists."
    echo "==> incrementing the version"
    echo "==> is this commit for a major, minor or patch update?"
    echo -n "[major|minor|patch]: "
    read increment
    increment_version $increment
  fi

  # if the incremented version is already tagged in the remote repo, the commit aborts and the user must manually set the version
  version_incremented=$(get_version ${VERSION_VARIABLE_MATCH})
  if tag_exists $version_incremented; then
    echo "==> the tag for the incremented version $version_incremented already exists. Please manually set the version in $VERSION_FILE"
    return 1
  fi
}

function install_pre_commit_hook(){
  echo "==> installing pre commit hook"
  mkdir -p .git/hooks
  cat > .git/hooks/pre-commit <<EOF
#!/bin/bash
exec < /dev/tty
./scripts/helpers.sh pre_commit
EOF

chmod 755 .git/hooks/pre-commit
}

function package(){
  mkdir -p ./artifacts
  tar czvf ./artifacts/deployment.tgz -C $PWD . --exclude=.$(basename $PWD) --exclude=./artifacts
}


eval $@
