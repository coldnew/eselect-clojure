# -*-eselect-*-  vim: ft=eselect
# Copyright 2005-2019 Gentoo Authors
# Distributed under the terms of the GNU GPL version 2 or later
# based on: https://github.com/Flawless/clojure.eselect

DESCRIPTION="Manage the /usr/bin/clojure symlink"
MAINTAINER="flawless@last-try.org"

# sort function for kernel versions, to be used in a pipe
sort_versions() {
    local vsort="sort --version-sort"
    # Test if our sort supports the --version-sort option
    # (should be GNU sort, since the kernel module is GNU/Linux specific)
    ${vsort} </dev/null &>/dev/null || vsort=sort

    # We sort kernel versions as follows:
    # 1. Run sed to prepend the version string by the numeric version
    #    and an additional rank indicator that is 0 for release candidates
    #    or 1 otherwise. After this step we have, for example:
    #      2.6.29 1 linux-2.6.29
    #      2.6.29 0 linux-2.6.29-rc8
    # 2. sort --version-sort
    # 3. Run sed again to remove the prepended keys from step 1.
    sed -e 's/^\(clojure-\)\?\([[:digit:].]\+\)[-_]rc/\2 0 &/' \
        -e 't;s/^\(clojure-\)\?\([[:digit:].]\+\)/\2 1 &/' \
        | LC_ALL=C ${vsort} | sed 's/.* //'
}

# find a list of kernel symlink targets
find_targets() {
    local f
    for f in "${EROOT}"/usr/bin/clojure-*; do
        basename "${f}"
    done | sort_versions
}

# remove the kernel symlink
remove_symlink() {
    rm -f "${EROOT}/usr/bin/clojure"
}

# set the kernel symlink
set_symlink() {
    local target=$1

    if is_number "${target}"; then
        local targets=( $(find_targets) )
        [[ ${target} -ge 1 && ${target} -le ${#targets[@]} ]] \
            || die -q "Number out of range: $1"
        target=${targets[target-1]}
    fi

    if [[ -n ${target} ]]; then
        if [[ -f ${EROOT}/usr/bin/${target} ]]; then
            :
        elif [[ -f ${EROOT}/usr/bin/clojure-${target} ]]; then
            target=clojure-${target}
        else					# target not valid
            target=
        fi
    fi
    [[ -n ${target} ]] || die -q "Target \"$1\" doesn't appear to be valid!"

    remove_symlink || die -q "Couldn't remove existing symlink"
    ln -s "${target}" "${EROOT}/usr/bin/clojure"
}

### show action ###

describe_show() {
    echo "Show the current clojure executable symlink"
}

do_show() {
    write_list_start "Current clojure symlink:"
    if [[ -L ${EROOT}/usr/bin/clojure ]]; then
        local clojure=$(canonicalise "${EROOT}/usr/bin/clojure")
        write_kv_list_entry "${clojure%/}" ""
        [[ -f ${clojure} ]] \
            || write_warning_msg "Symlink target doesn't appear to be valid!"
    else
        write_kv_list_entry "(unset)" ""
    fi
}

### list action ###

describe_list() {
    echo "List available clojure symlink executables"
}

do_list() {
    local i targets=( $(find_targets) )

    write_list_start "Available clojure symlink targets:"
    for (( i = 0; i < ${#targets[@]}; i++ )); do
        [[ ${targets[i]} = \
            $(basename "$(canonicalise "${EROOT}/usr/bin/clojure")") ]] \
            && targets[i]=$(highlight_marker "${targets[i]}")
    done
    write_numbered_list -m "(none found)" "${targets[@]}"
}

### set action ###

describe_set() {
    echo "Set a new clojure symlink executable"
}

describe_set_parameters() {
    echo "<target>"
}

describe_set_options() {
    echo "target : Target name or number (from 'list' action)"
}

do_set() {
    [[ -z $1 ]] && die -q "You didn't tell me what to set the symlink to"
    [[ $# -gt 1 ]] && die -q "Too many parameters"

    if [[ -e ${EROOT}/usr/bin/clojure && ! -L ${EROOT}/usr/bin/clojure ]]; then
        # we have something strange
        die -q "${EROOT}/usr/bin/clojure exists but is not a symlink"
    fi

    set_symlink "$1" || die -q "Couldn't set a new symlink"
}
