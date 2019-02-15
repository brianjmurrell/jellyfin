#!/usr/bin/env sh

. ../common.build.sh

VERSION=$(get_version ../..)

package_temporary_dir="$(pwd)/pkg-dist-tmp"
pkg_src_dir="$(pwd)/pkg-src"

GNU_TAR=1
echo "Bundling all sources for RPM build."
tar \
--transform "s,^\.,jellyfin-${VERSION}," \
--exclude='.git*' \
--exclude='**/.git' \
--exclude='**/.hg' \
--exclude='**/.vs' \
--exclude='**/.vscode' \
--exclude='deployment' \
--exclude='**/bin' \
--exclude='**/obj' \
--exclude='**/.nuget' \
--exclude='*.deb' \
--exclude='*.rpm' \
-Jcf "$pkg_src_dir/jellyfin-${VERSION}.tar.xz" \
-C "../.." ./ || GNU_TAR=0

if [ $GNU_TAR -eq 0 ]; then
    echo "The installed tar binary did not support --transform. Using workaround."
    mkdir -p "$package_temporary_dir/jellyfin-${VERSION}"
    # Not GNU tar
    tar \
    --exclude='.git*' \
    --exclude='**/.git' \
    --exclude='**/.hg' \
    --exclude='**/.vs' \
    --exclude='**/.vscode' \
    --exclude='deployment' \
    --exclude='**/bin' \
    --exclude='**/obj' \
    --exclude='**/.nuget' \
    --exclude='*.deb' \
    --exclude='*.rpm' \
    -zcf \
    "$package_temporary_dir/jellyfin-${VERSION}/jellyfin.tar.xz" \
    -C "../.." \
    ./
    echo "Extracting filtered package."
    tar -Jzf "$package_temporary_dir/jellyfin-${VERSION}/jellyfin.tar.xz" -C "$package_temporary_dir/jellyfin-${VERSION}"
    echo "Removing filtered package."
    rm "$package_temporary_dir/jellyfin-${VERSION}/jellyfin.tar.xz"
    echo "Repackaging package into final tarball."
    tar -Jcf "$pkg_src_dir/jellyfin-${VERSION}.tar.xz" -C "$package_temporary_dir" "jellyfin-${VERSION}"
fi
