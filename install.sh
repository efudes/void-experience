#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
package_arguments=
selection_file=$(mktemp)
trap 'rm -f -- "$selection_file"' EXIT HUP INT TERM

usage() {
    cat <<'EOF'
Usage: ./install.sh [--skip-packages] [--extras=LIST] [--shared-media-defaults] [--dry-run]

Run this script from an XFCE/Xorg session on Debian 13. It creates a complete
timestamped backup before changing user configuration. GNOME, GDM, dconf and
GNOME Shell are never modified.

--shared-media-defaults opts into making Celluloid the freedesktop default for
audio/video. That MIME choice is shared by XFCE and GNOME.

By default an optional-software checklist is shown. --extras=LIST makes the
selection non-interactive; see scripts/install-packages.sh --help.
EOF
}

skip_packages=false
shared_media_defaults=false
dry_run=false
for argument in "$@"; do
    case "$argument" in
        --skip-packages) skip_packages=true ;;
        --extras=*) package_arguments=$argument ;;
        --shared-media-defaults) shared_media_defaults=true ;;
        --dry-run) dry_run=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done

case "${XDG_CURRENT_DESKTOP-}:${XDG_SESSION_TYPE-}" in
    *XFCE*:x11) ;;
    *)
        echo "Run Void Experience after logging into an XFCE/Xorg session." >&2
        echo "Nothing was changed." >&2
        exit 1
        ;;
esac

if [ ! -r /etc/os-release ] ||
    ! grep -q '^ID=debian$' /etc/os-release ||
    ! grep -Eq '^(VERSION_ID=\"?13\"?|VERSION_CODENAME=trixie)$' /etc/os-release; then
    echo "This release is tested only on Debian 13 (trixie)." >&2
    exit 1
fi

if "$dry_run"; then
    echo "Dry run: prerequisites and session are compatible."
    "$project_dir/scripts/install-packages.sh" \
        ${package_arguments:+"$package_arguments"} --dry-run
    echo "Backup root: \$HOME/desktop-backups/void-experience/<timestamp>"
    echo "Apply command: $project_dir/scripts/apply.sh --all"
    exit 0
fi

if ! "$skip_packages"; then
    VOID_EXPERIENCE_SELECTION_FILE="$selection_file" \
        "$project_dir/scripts/install-packages.sh" \
        ${package_arguments:+"$package_arguments"}
fi

backup_id=$(date +%Y%m%d-%H%M%S)
"$project_dir/scripts/backup.sh" "$backup_id"
if "$shared_media_defaults"; then
    VOID_EXPERIENCE_SHARED_MEDIA_DEFAULTS=1 \
        "$project_dir/scripts/apply.sh" --all
else
    "$project_dir/scripts/apply.sh" --all
fi

case ",$(cat "$selection_file" 2>/dev/null || true)," in
    *,void-zsh,*)
        zsh_arguments=
        case ",$(cat "$selection_file" 2>/dev/null || true)," in
            *,codex-bypass,*) zsh_arguments=--codex-bypass ;;
        esac
        "$project_dir/scripts/install-void-zsh.sh" \
            --backup-id="$backup_id" ${zsh_arguments:+"$zsh_arguments"}
        printf "Make Zsh the default login shell too? [y/N] "
        read -r shell_answer
        case "$shell_answer" in
            y|Y|yes|YES)
                "$project_dir/scripts/install-void-zsh.sh" \
                    --backup-id="$backup_id" --make-default \
                    ${zsh_arguments:+"$zsh_arguments"}
                ;;
            *) echo "Login shell was not changed." ;;
        esac
        ;;
esac

printf '%s\n' "$backup_id" >"$HOME/.config/void-experience-backup"

echo
echo "Void Experience installed successfully."
echo "Backup: $HOME/desktop-backups/void-experience/$backup_id"
echo "Validate with: $project_dir/scripts/check.sh"
echo "Rollback with: $project_dir/scripts/rollback.sh $backup_id"
