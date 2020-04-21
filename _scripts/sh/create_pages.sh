#! /bin/bash
#
# Create HTML pages for Categories and Tags in posts.
#
# Usage:
#     Call from the '_posts' sibling directory.
#
# v2.2
# https://github.com/cotes2020/jekyll-theme-chirpy
# © 2020 Cotes Chung
# Published under MIT License

set -eu

category_count=0
tag_count=0

function parse_front_matter() {
  local _filename
  _filename=$1
  perl _scripts/pl/parse_front_matter.pl "$_filename"
  #  local _result
  #  _result=$(perl _scripts/sh/parse_front_matter.pl "$_filename" | grep "Category:" | head | sed 's/Category: *//')
  #
  #  for i in ${_result#,}; do
  #      echo "$i"
  #  done
}

read_categories() {
  # Only read the first 2 categories
  echo "$1" | grep "Category:" | head -2 | sed 's/Category: *//'
}

read_tags() {
  # Read all tags"
  echo "$1" | grep "Tag:" | head | sed 's/Tag: *//'
}

init() {
  if [[ -d categories ]]; then
    rm -rf categories
  fi

  if [[ -d tags ]]; then
    rm -rf tags
  fi

  mkdir categories tags
}

create_category() {
  local _name=$1
  local _filepath
  _filepath="categories/$(echo "$_name" | sed 's/ /-/g' | awk '{print tolower($0)}').html"

  if [[ ! -f $_filepath ]]; then
    {
      echo "---"
      echo "layout: category"
      echo "title: $_name"
      echo "category: $_name"
      echo "---"
    } >"$_filepath"

    ((category_count = category_count + 1))
  fi
}

create_tag() {
  local _name=$1
  local _filepath
  _filepath="tags/$(echo "$_name" | sed "s/ /-/g;s/'//g" | awk '{print tolower($0)}').html"

  if [[ ! -f $_filepath ]]; then
    {
      echo "---"
      echo "layout: tag"
      echo "title: $_name"
      echo "tag: $_name"
      echo "---"
    } >"$_filepath"

    ((tag_count = tag_count + 1))
  fi
}

main() {
  init

  local _posts
  _posts=$(ls "_posts")

  for _file in $_posts; do
    local _path="_posts/$_file"

    echo -e "Updating Posts: $_path\n"

    perl _scripts/pl/parse_front_matter.pl "$_path"

    local _front_matter
    _front_matter=$(parse_front_matter "$_path")

    local _categories
    _categories=$(read_categories "$_front_matter")
    local _tags
    _tags=$(read_tags "$_front_matter")

    for i in ${_categories#,}; do
      echo "Category: $i"
      create_category "$i"
    done

    for i in ${_tags#,}; do
      echo "Tag: $i"
      create_tag "$i"
    done
  done

  if [[ $category_count -gt 0 ]]; then
    echo "[INFO] Succeed! $category_count category-pages created."
  fi

  if [[ $tag_count -gt 0 ]]; then
    echo "[INFO] Succeed! $tag_count tag-pages created."
  fi
}

main
