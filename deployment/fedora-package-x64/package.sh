#!/usr/bin/env bash

source ../common.build.sh

WORKDIR="$( pwd )"
VERSION="$( grep '^Version:' ${WORKDIR}/pkg-src/jellyfin.spec | awk '{ print $NF }' )"

package_temporary_dir="${WORKDIR}/pkg-dist-tmp"
output_dir="${WORKDIR}/pkg-dist"
pkg_src_dir="${WORKDIR}/pkg-src"
current_user="$( whoami )"
image_name="jellyfin-fedora-build"

# Determine if sudo should be used for Docker
if [[ ! -z $(id -Gn | grep -q 'docker') ]] \
  && [[ ! ${EUID:-1000} -eq 0 ]] \
  && [[ ! ${USER} == "root" ]] \
  && [[ ! -z $( echo "${OSTYPE}" | grep -q "darwin" ) ]]; then
    docker_sudo="sudo"
else
    docker_sudo=""
fi

./create_tarball.sh

# Set up the build environment Docker image
${docker_sudo} docker build ../.. -t "${image_name}" -f ./Dockerfile
# Build the RPMs and copy out to ${package_temporary_dir}
${docker_sudo} docker run --rm -v "${package_temporary_dir}:/dist" "${image_name}"
# Correct ownership on the RPMs (as current user, then as root if that fails)
chown -R "${current_user}" "${package_temporary_dir}" \
  || sudo chown -R "${current_user}" "${package_temporary_dir}"
# Move the RPMs to the output directory
mkdir -p "${output_dir}"
mv "${package_temporary_dir}"/rpm/* "${output_dir}"
