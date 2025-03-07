validate_parent_dir_exists() {
  [[ -d "$(dirname $1)" ]] || echo "Parent directory of $1 does not exist."
}