#GLOBAL SCOPED VARIABLES
COMMIT_MESSAGE=""
VERSION_INCREMENT_TYPE="patch"


get_commit_message_from_git() {
  echo $(git log -1 --pretty=%B)
}

get_semantic_version_from_git () {
  local latest_tag=$(git rev-list --tags --max-count=1)
  if [ -z "$latest_tag" ]
  then
        echo ""
        return
  fi
  local git_version=$(git describe --tags $latest_tag)
  echo "$git_version"
}

get_increment_semantic_type_from_message() {
  local message="$1"
  if [[ $message == *"[MAJOR]"* ]]; then
      echo "major"
  elif [[ $message == *"[MINOR]"* ]]; then
      echo "minor"
  else
      echo "patch"
  fi
}

get_incremented_semantic_version () {
  local increment_type=$1
  local current_version=$2
  if [ -z "$current_version" ]
  then
        current_version="1.0.0"
  fi
  local semantic_version=$(increment_semantic_version $increment_type $current_version)
  echo "${version_prefix}$semantic_version"
}

increment_semantic_version() {
  local increment_type=$1
  local current_version=$( echo $2 | tr -dc '0-9.' )
  local version_array=( ${current_version//./ } )
  case $increment_type in
    "major" )
      ((version_array[0]++))
      version_array[1]=0
      version_array[2]=0
      ;;
    "minor" )
      ((version_array[1]++))
      version_array[2]=0
      ;;
    "patch" )
      ((version_array[2]++))
      ;;
  esac

  echo "${version_array[0]}.${version_array[1]}.${version_array[2]}"
}

set_semantic_version_to_git () {
  local tag_version="$1"
  local tag_message="$2"
  if [ -z "$tag_message" ]
  then
        tag_message="Release for version ${tag_version}"
  fi
  git tag -a "${tag_version}" -m "${tag_message}"
  git push origin "${tag_version}"
}


#PROGRAM STARTS HERE
COMMIT_MESSAGE=$(get_commit_message_from_git)
VERSION_INCREMENT_TYPE=$(get_increment_semantic_type_from_message "$COMMIT_MESSAGE")
CURRENT_VERSION=$(get_semantic_version_from_git)

echo $COMMIT_MESSAGE
echo $VERSION_INCREMENT_TYPE
echo $CURRENT_VERSION

