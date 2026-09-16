alias build-vm := build-qcow2
alias rebuild-vm := rebuild-qcow2
alias run-vm := run-vm-qcow2

[private]
default:
    @just --list

# Check Just Syntax
[group('Just')]
check:
    #!/usr/bin/env bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt --check -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt --check -f Justfile

# Fix Just Syntax
[group('Just')]
fix:
    #!/usr/bin/env bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt -f Justfile || { exit 1; }

# Clean Repo
[group('Utility')]
clean:
    #!/usr/bin/env bash
    set -eoux pipefail
    touch _build
    find *_build* -exec rm -rf {} \;
    rm -f previous.manifest.json
    rm -f changelog.md
    rm -f output.env
    rm -rf output/

# Sudo Clean Repo
[group('Utility')]
[private]
sudo-clean:
    just sudoif just clean

# sudoif bash function
[group('Utility')]
[private]
sudoif command *args:
    #!/usr/bin/env bash
    function sudoif(){
        if [[ "${UID}" -eq 0 ]]; then
            "$@"
        elif [[ "$(command -v sudo)" && -n "${SSH_ASKPASS:-}" ]] && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
            sudo --askpass "$@" || exit 1
        elif [[ "$(command -v sudo)" ]]; then
            sudo "$@" || exit 1
        else
            exit 1
        fi
    }
    sudoif {{ command }} {{ args }}

# Load per-image metadata from images/<target_image>/image.env into the
# current shell. Strips a leading "localhost/" so callers can pass either
# "asteroid-lts" or "localhost/asteroid-lts" and still find the right file.
# Meant to be sourced (via `source`), not run directly.
[private]
_load-image-env target_image:
    #!/usr/bin/env bash
    set -euo pipefail
    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    env_file="./images/${image_dir}/image.env"
    if [[ ! -f "${env_file}" ]]; then
        echo "No image.env found at ${env_file}" >&2
        exit 1
    fi
    cat "${env_file}"

# This Justfile recipe builds a container image using Podman.
#
# Arguments:
#   $target_image - The image directory / tag to build, e.g. "asteroid" or "asteroid-lts".
#                    Metadata (IMAGE_DESC, REPO_ORGANIZATION, etc.) is read from
#                    ./images/$target_image/image.env, not from a Justfile-level .env.
#   $tag - The tag for the image. Empty by default, in which case DEFAULT_TAG
#          from that image's image.env is used.
#
# The script constructs the version string using the tag and the current date.
# If the git working directory is clean, it also includes the short SHA of the current HEAD.
#
# Example usage:
#   just build asteroid-lts
#   just build asteroid-lts stable

# Build the image using the specified parameters
build $target_image $tag="" *extra_args="":
    #!/usr/bin/env bash

    set -euox pipefail

    source ./images/{{ target_image }}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    BUILD_ARGS+=("--build-arg" "BUILD_ID=$(git rev-parse HEAD 2>/dev/null || date +%s)")
    LABELS=()
    if [[ -z "$(git status -s)" ]]; then
        GIT_SHA=$(git rev-parse --short HEAD)
        LABELS+=("--label" "io.artifacthub.package.readme-url=https://raw.githubusercontent.com/${REPO_ORGANIZATION}/{{ target_image }}/${GIT_SHA}/README.md")
        LABELS+=("--label" "org.opencontainers.image.documentation=https://raw.githubusercontent.com/${REPO_ORGANIZATION}/{{ target_image }}/${GIT_SHA}/README.md")
        LABELS+=("--label" "org.opencontainers.image.source=https://github.com/${REPO_ORGANIZATION}/{{ target_image }}/blob/${GIT_SHA}/Containerfile")
        LABELS+=("--label" "org.opencontainers.image.url=https://github.com/${REPO_ORGANIZATION}/{{ target_image }}/tree/${GIT_SHA}")
        LABELS+=("--label" "org.opencontainers.image.version=${tag}.$(date +%Y%m%d)-${GIT_SHA}")
    fi

    # Image metadata for https://artifacthub.io/ - This is optional but is highly recommended so we all can get a index of all the custom images
    # The metadata by itself is not going to do anything, you choose if you want your image to be on ArtifactHub or not.
    LABELS+=("--label" "io.artifacthub.package.deprecated=false")
    LABELS+=("--label" "io.artifacthub.package.keywords=${IMAGE_KEYWORDS}")
    LABELS+=("--label" "io.artifacthub.package.license=Apache-2.0")
    LABELS+=("--label" "io.artifacthub.package.logo-url=${IMAGE_LOGO_URL}")
    LABELS+=("--label" "io.artifacthub.package.prerelease=false")
    LABELS+=("--label" "org.opencontainers.image.created=$(date -u +%Y\-%m\-%d\T%H\:%M\:%S\Z)")
    LABELS+=("--label" "org.opencontainers.image.description=${IMAGE_DESC}")
    LABELS+=("--label" "org.opencontainers.image.title={{ target_image }}")
    LABELS+=("--label" "org.opencontainers.image.vendor=${REPO_ORGANIZATION}")

    # This actually builds the image!
    PODMAN_BUILD_ARGS=("${BUILD_ARGS[@]}" "${LABELS[@]}" --pull=newer --tag "{{ target_image }}:${tag}" --file ./images/{{ target_image }}/Containerfile)

    podman build "${PODMAN_BUILD_ARGS[@]}" {{ extra_args }} .

# Split the image for smaller updates (New)!
rechunk $target_image $tag="":
    #!/usr/bin/env bash

    set -xeuo pipefail

    source ./images/{{ target_image }}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    # TODO: pin chunkah image to hash once mature enough
    # You may run into space issues on github runners as we are making a
    # complete copy of the image, which likely has no shared layers, unless your
    # base image is also using chunkah
    CHUNKAH_CONFIG_FILE="$(mktemp)"

    # You may omit the current directory here if you are confident that you
    # wont run out of space on /tmp for your image
    CHUNKAH_OUTPUT_DIR="$(mktemp -d ./"{{ target_image }}"_chunkah_XXXXXX)"

    trap 'rm -f "${CHUNKAH_CONFIG_FILE}"; rm -rf "${CHUNKAH_OUTPUT_DIR}"' EXIT
    podman inspect "{{ target_image }}:${tag}" > "${CHUNKAH_CONFIG_FILE}"

    podman run --rm \
      --mount=type=image,src="{{ target_image }}:${tag}",target=/chunkah \
      -v "${CHUNKAH_CONFIG_FILE}:/chunkah-config.json:ro,Z" \
      -v "${CHUNKAH_OUTPUT_DIR}:/run/out:Z" \
      quay.io/coreos/chunkah:latest \
      build \
      --verbose \
      --compressed \
      --max-layers 128 \
      --prune /sysroot/ \
      --label ostree.commit- --label ostree.final-diffid- \
      --config /chunkah-config.json \
      --output oci:/run/out/chunked

    CHUNKED_IMAGE="$(podman pull "oci:${CHUNKAH_OUTPUT_DIR}/chunked")"
    podman tag "${CHUNKED_IMAGE}" "{{ target_image }}:${tag}"

# Split the image for smaller updates (Classical)!
ostree-rechunk $target_image $tag="":
    #!/usr/bin/env bash

    set -xeuo pipefail

    source ./images/{{ target_image }}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    # Use the already-built local image to avoid pulling from a remote registry
    RPM_OSTREE_CHUNKER_IMAGE="localhost/{{ target_image }}:${tag}"

    GRAPHROOT="$(podman info --format '{{ '{{.Store.GraphRoot}}' }}')"

    podman run --rm --pull=never --privileged \
      --mount=type=image,src="{{ target_image }}:${tag}",target=/rpm-ostree \
      --mount=type=bind,src=${GRAPHROOT},target=/run/host-container-storage,rw \
      --mount=type=tmpfs,target=/run/rpm-ostree-storage \
      --entrypoint /usr/bin/rpm-ostree \
      "${RPM_OSTREE_CHUNKER_IMAGE}" \
      compose build-chunked-oci \
      --max-layers 127 \
      --format-version=2 \
      --bootc \
      --rootfs /rpm-ostree \
      --output "containers-storage:[overlay@/run/host-container-storage+/run/rpm-ostree-storage]localhost/{{ target_image }}:${tag}"

# Generate Default Tag
[group('Utility')]
generate-default-tag target_image $tag="":
    #!/usr/bin/env bash
    set -eoux pipefail

    source ./images/{{ target_image }}/image.env
    tag="${tag:-${DEFAULT_TAG}}"

    echo "${tag}"

# Generate Tags
[group('Utility')]
generate-build-tags $target_image $tag="":
    #!/usr/bin/env bash
    set -eoux pipefail

    source ./images/{{ target_image }}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    DATE=$(date +%Y%m%d)
    BUILD_TAGS=()
    if [[ -z "$(git status -s)" ]]; then
        GIT_SHA=$(git rev-parse --short HEAD)
        BUILD_TAGS+=("${tag}-${GIT_SHA}")
        BUILD_TAGS+=("${tag}-${DATE}-${GIT_SHA}")
        BUILD_TAGS+=("${DATE}-${GIT_SHA}")
    fi

    BUILD_TAGS+=("${DATE}")
    BUILD_TAGS+=("${tag}")
    BUILD_TAGS+=("${tag}-${DATE}")

    echo "${BUILD_TAGS[@]}"

# Tag Images
[group('Utility')]
tag-images $target_image $tag="" tags="":
    #!/usr/bin/env bash
    set -eoux pipefail

    source ./images/{{ target_image }}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    # Get Image, and untag
    IMAGE=$(podman inspect {{ target_image }}:${tag} | jq -r .[].Id)
    podman untag ${IMAGE}

    # Tag Image
    for tag in {{ tags }}; do
        podman tag $IMAGE "{{ target_image }}:${tag}"
    done

    # Show Images
    podman images

# Command: _rootful_load_image
# Description: This script checks if the current user is root or running under sudo. If not, it attempts to resolve the image tag using podman inspect.
#              If the image is found, it loads it into rootful podman. If the image is not found, it pulls it from the repository.
#
# Parameters:
#   $target_image - The name of the target image to be loaded or pulled.
#   $tag - The tag of the target image to be loaded or pulled. Empty resolves to that image's DEFAULT_TAG.
#
# Example usage:
#   _rootful_load_image asteroid-lts latest
#
# Steps:
# 1. Check if the script is already running as root or under sudo.
# 2. Check if target image is in the non-root podman container storage)
# 3. If the image is found, load it into rootful podman using podman scp.
# 4. If the image is not found, pull it from the remote repository into reootful podman.

_rootful_load_image $target_image $tag="":
    #!/usr/bin/env bash
    set -eoux pipefail

    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    source ./images/${image_dir}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    # Check if already running as root or under sudo
    if [[ -n "${SUDO_USER:-}" || "${UID}" -eq "0" ]]; then
        echo "Already root or running under sudo, no need to load image from user podman."
        exit 0
    fi

    # Try to resolve the image tag using podman inspect
    set +e
    resolved_tag=$(podman inspect -t image "{{ target_image }}:${tag}" | jq -r '.[].RepoTags.[0]')
    return_code=$?
    set -e

    USER_IMG_ID=$(podman images --filter reference="{{ target_image }}:${tag}" --format "'{{ '{{.ID}}' }}'")

    if [[ $return_code -eq 0 ]]; then
        # If the image is found, load it into rootful podman
        ID=$(just sudoif podman images --filter reference="{{ target_image }}:${tag}" --format "'{{ '{{.ID}}' }}'")
        if [[ "$ID" != "$USER_IMG_ID" ]]; then
            # If the image ID is not found or different from user, copy the image from user podman to root podman
            COPYTMP=$(mktemp -p "${PWD}" -d -t _build_podman_scp.XXXXXXXXXX)
            just sudoif TMPDIR=${COPYTMP} podman image scp ${UID}@localhost::"{{ target_image }}:${tag}" root@localhost::"{{ target_image }}:${tag}"
            rm -rf "${COPYTMP}"
        fi
    else
        # If the image is not found, pull it from the repository
        just sudoif podman pull "{{ target_image }}:${tag}"
    fi

# Build a bootc bootable image using Bootc Image Builder (BIB)
# Converts a container image to a bootable image
# Parameters:
#   target_image: The name of the image to build (ex. localhost/asteroid-lts)
#   tag: The tag of the image to build (ex. latest)
#   type: The type of image to build (ex. qcow2, raw, iso)
#   config: The configuration file to use for the build (default: disk_config/disk.toml)

# Run bootc directly against a container image inside rootful Podman
# Example: just bootc asteroid-lts latest -- --help
# Run bootc directly against a container image inside rootful Podman
# Example: just bootc asteroid-lts latest -- --help
# Run bootc directly against a container image inside rootful Podman
# Example: just bootc asteroid-lts latest -- --help
[private]
bootc $target_image $tag="" *ARGS: (_rootful_load_image target_image tag)
    #!/usr/bin/env bash
    set -euo pipefail

    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    source ./images/${image_dir}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    BOOTC_INSTALL_OPTIONS=()
    BOOTC_INSTALL_OPTIONS+=("-v" "/var/lib/containers/storage:/var/lib/containers/storage")
    BOOTC_INSTALL_OPTIONS+=("-v" "/etc/containers:/etc/containers")
    BOOTC_INSTALL_OPTIONS+=("-v" "/dev:/dev")
    BOOTC_INSTALL_OPTIONS+=("-v" "/sys:/sys")
    BOOTC_INSTALL_OPTIONS+=("-v" "/run:/run")

    if [[ -d /sys/firmware/efi ]]; then
        BOOTC_INSTALL_OPTIONS+=("-v" "/sys/firmware/efi:/sys/firmware/efi")
    fi

    if [[ -d /sys/fs/selinux ]]; then
        BOOTC_INSTALL_OPTIONS+=("-v" "/sys/fs/selinux:/sys/fs/selinux" "--security-opt" "label=type:unconfined_t")
    fi

    just sudoif podman run \
        --rm --privileged --pid=host \
        -it \
        "${BOOTC_INSTALL_OPTIONS[@]}" \
        -v "${PWD}:/data" \
        "localhost/${image_dir}:${tag}" bootc {{ ARGS }}

# Create a raw bootable disk image using `bootc install to-disk`
# Arguments:
#   target_image: Name of image directory (e.g. asteroid-lts)
#   tag: Image tag (defaults to DEFAULT_TAG in image.env)
#   backend: OSTree backend ("ostree" or "composefs")
#   img_size: Size allocated for the raw disk image (default: 40G)
#
# Example: just disk-image asteroid-lts latest ostree 35G
# Create a raw bootable disk image using `bootc install to-disk`
# Arguments:
#   target_image: Name of image directory (e.g. asteroid-lts)
#   tag: Image tag (defaults to DEFAULT_TAG in image.env)
#   backend: OSTree backend ("ostree" or "composefs")
#   img_size: Size allocated for the raw disk image (default: 40G)
#   fs_type: Root filesystem type ("btrfs", "ext4", or "xfs")
#
# Example: just disk-image asteroid-lts latest ostree 35G btrfs
# Create a raw bootable disk image using `bootc install to-disk`
# Arguments:
#   target_image: Name of image directory (e.g. asteroid-lts)
#   tag: Image tag (defaults to DEFAULT_TAG in image.env)
#   backend: OSTree backend ("ostree" or "composefs")
#   img_size: Size allocated for the raw disk image (default: 40G)
#   fs_type: Root filesystem type ("btrfs", "ext4", or "xfs")
#
# Example: just disk-image asteroid-lts latest ostree 35G btrfs
# Create a raw bootable disk image using `bootc install to-disk`
# Arguments:
#   target_image: Name of image directory (e.g. asteroid-lts)
#   tag: Image tag (defaults to DEFAULT_TAG in image.env)
#   backend: OSTree backend ("ostree" or "composefs")
#   img_size: Size allocated for the raw disk image (default: 40G)
#   fs_type: Root filesystem type ("btrfs", "ext4", or "xfs")
#
# Example: just disk-image asteroid-lts latest ostree 35G btrfs
[group('Build Virtual Machine Image')]
disk-image $target_image $tag="" $backend="ostree" $img_size="40G" $fs_type="btrfs":
    #!/usr/bin/env bash
    set -euo pipefail

    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    source ./images/${image_dir}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    BYTES_IMAGE_SIZE=$(numfmt --from=iec "{{ img_size }}")

    if [ ! -e "bootable.img" ]; then
        FREE_SPACE=$(findmnt -bno AVAIL -T ".")
        if [ "${FREE_SPACE}" -gt "${BYTES_IMAGE_SIZE}" ]; then
            fallocate -l "${BYTES_IMAGE_SIZE}" "bootable.img"
        else
            echo "Not enough disk space available" >&2
            exit 1
        fi
    fi

    BOOTC_INSTALL_ARGS=()
    BOOTC_INSTALL_ARGS+=("--generic-image" "--via-loopback" "/data/bootable.img" "--wipe")
    BOOTC_INSTALL_ARGS+=("--filesystem" "{{ fs_type }}")
    BOOTC_INSTALL_ARGS+=("--source-imgref" "containers-storage:localhost/${image_dir}:${tag}")

    if [[ "{{ backend }}" == "ostree" ]]; then
        BOOTC_INSTALL_ARGS+=("--bootloader" "grub")
    else
        BOOTC_INSTALL_ARGS+=("--bootloader" "grub" "--composefs-backend")
    fi

    just bootc "{{ target_image }}" "{{ tag }}" install to-disk "${BOOTC_INSTALL_ARGS[@]}"

# Example: just _build-bib localhost/asteroid-lts latest qcow2 disk_config/disk.toml
# Build a bootable disk/installer image using Titanoboa
#
# Parameters:
#   target_image: Name of image directory (e.g. asteroid-lts)
#   tag: Image tag (defaults to DEFAULT_TAG in image.env)
#   type: Output image format (qcow2, raw, iso)
#   config: Path to partitioning schema or config file (e.g. disk_config/disk.toml)
_build-titanoboa $target_image $tag $type $config: (_rootful_load_image target_image tag)
    #!/usr/bin/env bash
    set -euo pipefail

    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    source ./images/${image_dir}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    BUILDTMP=$(mktemp -p "${PWD}" -d -t _build-titanoboa.XXXXXXXXXX)

    # TITANOBOA_IMAGE can be defined in your image.env (e.g. ghcr.io/ublue-os/titanoboa:latest)
    TITANOBOA_BIN="${TITANOBOA_IMAGE:-ghcr.io/ublue-os/titanoboa:latest}"

    sudo podman run \
      --rm \
      -it \
      --privileged \
      --net=host \
      --security-opt label=disable \
      -v $(pwd)/{{ config }}:/config.toml:ro \
      -v $BUILDTMP:/output \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      "${TITANOBOA_BIN}" \
      build \
      --target-type "{{ type }}" \
      --config /config.toml \
      "containers-storage:localhost/${image_dir}:${tag}" \
      /output

    mkdir -p output/{{ type }}
    sudo mv -f $BUILDTMP/* output/{{ type }}/ 2>/dev/null || sudo mv -f $BUILDTMP/* output/
    sudo rmdir $BUILDTMP
    sudo chown -R $USER:$USER output/

# Podman builds the image from the Containerfile and creates a bootable image
# Parameters:
#   target_image: The name of the image to build (ex. asteroid-lts)
#   tag: The tag of the image to build (ex. latest)
#   type: The type of image to build (ex. qcow2, raw, iso)
#   config: The configuration file to use for the build (default: disk_config/disk.toml)

_rebuild-titanoboa $target_image $tag $type $config: (build target_image tag) && (_build-titanoboa target_image tag type config)

# VM Build Aliases
[group('Build Virtual Machine Image')]
build-qcow2 target_image tag="": && (_build-titanoboa (target_image) tag "qcow2" "disk_config/disk.toml")

[group('Build Virtual Machine Image')]
build-raw target_image tag="": && (_build-titanoboa (target_image) tag "raw" "disk_config/disk.toml")

[group('Build Virtual Machine Image')]
build-iso target_image tag="": && (_build-titanoboa (target_image) tag "iso" "disk_config/iso.toml")

[group('Build Virtual Machine Image')]
rebuild-qcow2 target_image tag="": && (_rebuild-titanoboa (target_image) tag "qcow2" "disk_config/disk.toml")

[group('Build Virtual Machine Image')]
rebuild-raw target_image tag="": && (_rebuild-titanoboa (target_image) tag "raw" "disk_config/disk.toml")

[group('Build Virtual Machine Image')]
rebuild-iso target_image tag="": && (_rebuild-titanoboa (target_image) tag "iso" "disk_config/iso.toml")

# Run a virtual machine with the specified image type and configuration
_run-vm $target_image $tag $type $config:
    #!/usr/bin/env bash
    set -eoux pipefail

    image_dir="{{ target_image }}"
    image_dir="${image_dir#localhost/}"
    source ./images/${image_dir}/image.env
    tag="{{ tag }}"
    tag="${tag:-${DEFAULT_TAG}}"

    # Determine the image file based on the type
    image_file="output/{{ type }}/disk.{{ type }}"
    if [[ {{ type }} == iso ]]; then
        image_file="output/bootiso/install.iso"
    fi

    # Build the image if it does not exist
    if [[ ! -f "${image_file}" ]]; then
        just "build-{{ type }}" "${image_dir}" "${tag}"
    fi

    # Determine an available port to use
    port=8006
    while grep -q :${port} <<< $(ss -tunalp); do
        port=$(( port + 1 ))
    done
    echo "Using Port: ${port}"
    echo "Connect to http://localhost:${port}"

    # Set up the arguments for running the VM
    run_args=()
    run_args+=(--rm --privileged)
    run_args+=(--pull=newer)
    run_args+=(--publish "127.0.0.1:${port}:8006")
    run_args+=(--env "CPU_CORES=4")
    run_args+=(--env "RAM_SIZE=8G")
    run_args+=(--env "DISK_SIZE=64G")
    run_args+=(--env "TPM=Y")
    run_args+=(--env "GPU=Y")
    run_args+=(--device=/dev/kvm)
    run_args+=(--volume "${PWD}/${image_file}":"/boot.{{ type }}")
    run_args+=(docker.io/qemux/qemu)

    # Run the VM and open the browser to connect
    (sleep 30 && xdg-open http://localhost:"$port") &
    podman run "${run_args[@]}"

# Run a virtual machine from a QCOW2 image
[group('Run Virtal Machine')]
run-vm-qcow2 target_image tag="": && (_run-vm (target_image) tag "qcow2" "disk_config/disk.toml")

# Run a virtual machine from a RAW image
[group('Run Virtal Machine')]
run-vm-raw target_image tag="": && (_run-vm (target_image) tag "raw" "disk_config/disk.toml")

# Run a virtual machine from an ISO
[group('Run Virtal Machine')]
run-vm-iso target_image tag="": && (_run-vm (target_image) tag "iso" "disk_config/iso.toml")

# Run a virtual machine using systemd-vmspawn
[group('Run Virtal Machine')]
spawn-vm target_image rebuild="0" type="qcow2" ram="6G":
    #!/usr/bin/env bash

    set -euo pipefail

    [ "{{ rebuild }}" -eq 1 ] && echo "Rebuilding the ISO" && just build-vm "{{ target_image }}" "{{ type }}"

    systemd-vmspawn \
      -M "bootc-image" \
      --console=gui \
      --cpus=2 \
      --ram=$(echo {{ ram }}| numfmt --from=iec) \
      --network-user-mode \
      --vsock=false --pass-ssh-key=false \
      -i ./output/**/*.{{ type }}

# Runs shell check on all Bash scripts
lint:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shellcheck is installed
    if ! command -v shellcheck &> /dev/null; then
        echo "shellcheck could not be found. Please install it."
        exit 1
    fi
    # Run shellcheck on all Bash scripts
    find . -iname "*.sh" -type f -exec shellcheck "{}" ';'

# Runs shfmt on all Bash scripts
format:
    #!/usr/bin/env bash
    set -eoux pipefail
    # Check if shfmt is installed
    if ! command -v shfmt &> /dev/null; then
        echo "shfmt could not be found. Please install it."
        exit 1
    fi
    # Run shfmt on all Bash scripts
    find . -iname "*.sh" -type f -exec shfmt --write "{}" ';'
