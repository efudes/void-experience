#!/bin/sh
set -eu

project_dir=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT HUP INT TERM

mock_dir="$test_root/mock-bin"
test_log="$test_root/mock.log"
mkdir -p "$mock_dir"

cat >"$mock_dir/void-mock" <<'EOF'
#!/bin/sh
name=${0##*/}
case "$name" in
    xrandr)
        case "${1-}" in
            --listactivemonitors)
                if [ "${VOID_TEST_MONITORS-2}" = 1 ]; then
                    cat <<'OUTPUT'
Monitors: 1
 0: +*DP-1 1920/520x1080/290+0+0  DP-1
OUTPUT
                else
                    cat <<'OUTPUT'
Monitors: 2
 0: +HDMI-1 1920/520x1080/290+0+0  HDMI-1
 1: +*DP-1 1920/520x1080/290+1920+0  DP-1
OUTPUT
                fi
                ;;
            *)
                if [ "${VOID_TEST_MONITORS-2}" = 1 ]; then
                    cat <<'OUTPUT'
DP-1 connected primary 1920x1080+0+0
OUTPUT
                else
                    cat <<'OUTPUT'
HDMI-1 connected 1920x1080+0+0
DP-1 connected primary 1920x1080+1920+0
OUTPUT
                fi
                ;;
        esac
        ;;
    xdg-user-dir) printf '%s/Desktop\n' "$HOME" ;;
    xfconf-query)
        printf '%s\n' "$*" >>"$VOID_TEST_LOG"
        ;;
    pgrep) exit 1 ;;
    picom)
        printf 'picom %s\n' "$*" >>"$VOID_TEST_LOG"
        case "$*" in
            *'--diagnostics'*)
                [ "${VOID_TEST_PICOM_ALL_FAIL-0}" != 1 ] || exit 1
                ;;
        esac
        case "$*" in
            *'/picom.conf --diagnostics'*)
                [ "${VOID_TEST_PICOM_GLX_FAIL-0}" != 1 ] || exit 1
                ;;
        esac
        exit 0
        ;;
    xfce4-panel-profiles)
        case "${1-}" in
            save)
                mkdir -p "$(dirname -- "$2")"
                printf 'mock panel profile\n' >"$2"
                ;;
            load) printf 'panel-load %s\n' "$2" >>"$VOID_TEST_LOG" ;;
        esac
        ;;
    *) exit 0 ;;
esac
EOF
chmod 0755 "$mock_dir/void-mock"

for command_name in \
    xrandr xdg-user-dir xfconf-query pgrep pkill picom rofi wmctrl xdotool \
    xfce4-panel xfdesktop xfce4-screensaver-command celluloid sushi thunar \
    gtk-update-icon-cache xfce4-panel-profiles fc-cache; do
    ln -s void-mock "$mock_dir/$command_name"
done

tree_digest() {
    target_root=$1
    (
        cd "$target_root"
        find . -type f -o -type l |
            sort |
            while IFS= read -r item; do
                if [ -L "$item" ]; then
                    printf 'L %s %s\n' "$item" "$(readlink "$item")"
                else
                    sha256sum "$item"
                fi
            done
    )
}

apply_home="$test_root/apply-home"
mkdir -p "$apply_home"
: >"$test_log"
for run in 1 2; do
    HOME="$apply_home" \
    XDG_CURRENT_DESKTOP=XFCE \
    XDG_SESSION_TYPE=x11 \
    VOID_TEST_LOG="$test_log" \
    PATH="$mock_dir:$PATH" \
        "$project_dir/scripts/apply.sh" --all >/dev/null
    tree_digest "$apply_home" >"$test_root/apply-$run.digest"
done
grep -Fq "Exec=\"$apply_home/.local/bin/void-experience-picom\"" \
    "$apply_home/.config/autostart/void-experience-picom.desktop"
if grep -Fq '$HOME' "$apply_home/.config/autostart/void-experience-picom.desktop"; then
    echo "FAIL: generated autostart contains an unexpanded HOME" >&2
    exit 1
fi
cmp -s "$test_root/apply-1.digest" "$test_root/apply-2.digest" || {
    echo "FAIL: second apply changed the generated file tree" >&2
    diff -u "$test_root/apply-1.digest" "$test_root/apply-2.digest" || true
    exit 1
}

grep -Fq '/panels/panel-81/output-name -n -t string -s DP-1' "$test_log" || {
    echo "FAIL: primary monitor was not assigned panel 81" >&2
    exit 1
}
grep -Fq '/panels/panel-82/output-name -n -t string -s HDMI-1' "$test_log" || {
    echo "FAIL: secondary monitor was not assigned panel 82" >&2
    exit 1
}

single_home="$test_root/single-home"
single_log="$test_root/single.log"
mkdir -p "$single_home"
: >"$single_log"
HOME="$single_home" \
XDG_CURRENT_DESKTOP=XFCE \
XDG_SESSION_TYPE=x11 \
VOID_TEST_MONITORS=1 \
VOID_TEST_LOG="$single_log" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/apply.sh" --all >/dev/null
grep -Fq '/panels/panel-81/output-name -n -t string -s DP-1' "$single_log"
if grep -Fq '/panels/panel-82/output-name' "$single_log"; then
    echo "FAIL: single-monitor fixture created a second panel" >&2
    exit 1
fi

gpu_home="$test_root/gpu-home"
gpu_log="$test_root/gpu.log"
mkdir -p "$gpu_home"
: >"$gpu_log"
HOME="$gpu_home" \
XDG_CURRENT_DESKTOP=XFCE \
XDG_SESSION_TYPE=x11 \
VOID_TEST_PICOM_GLX_FAIL=1 \
VOID_TEST_LOG="$gpu_log" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/apply.sh" --all >/dev/null
grep -Fq "picom --config $gpu_home/.config/picom/picom-xrender.conf --diagnostics" \
    "$gpu_log" || {
    echo "FAIL: XRender fallback was not tested after GLX failure" >&2
    exit 1
}

no_compositor_home="$test_root/no-compositor-home"
no_compositor_log="$test_root/no-compositor.log"
mkdir -p "$no_compositor_home"
: >"$no_compositor_log"
if HOME="$no_compositor_home" \
    XDG_CURRENT_DESKTOP=XFCE \
    XDG_SESSION_TYPE=x11 \
    VOID_TEST_PICOM_ALL_FAIL=1 \
    VOID_TEST_LOG="$no_compositor_log" \
    PATH="$mock_dir:$PATH" \
        "$project_dir/scripts/apply.sh" --all >/dev/null 2>&1; then
    echo "FAIL: apply unexpectedly accepted two failed Picom backends" >&2
    exit 1
fi
grep -Fq '/general/use_compositing -s true' "$no_compositor_log" || {
    echo "FAIL: xfwm compositor was not restored after Picom failure" >&2
    exit 1
}

rollback_home="$test_root/rollback-home"
mkdir -p \
    "$rollback_home/.config/xfce4" \
    "$rollback_home/.config/kitty" \
    "$rollback_home/.local/bin" \
    "$rollback_home/Desktop"
printf 'baseline-xfce\n' >"$rollback_home/.config/xfce4/value"
printf '# baseline-zsh\n' >"$rollback_home/.zshrc"
printf 'baseline-kitty\n' >"$rollback_home/.config/kitty/kitty.conf"
printf 'baseline-layout\n' >"$rollback_home/.local/bin/void-layout"
printf 'baseline-desktop\n' >"$rollback_home/Desktop/user.txt"

HOME="$rollback_home" \
XDG_CURRENT_DESKTOP=XFCE \
XDG_SESSION_TYPE=x11 \
VOID_TEST_LOG="$test_log" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/backup.sh" 20000101-000000 >/dev/null

"$project_dir/scripts/install-void-zsh.sh" \
    --dry-run >/dev/null
HOME="$rollback_home" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/install-void-zsh.sh" \
    --backup-id=20000101-000000 >/dev/null
HOME="$rollback_home" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/install-void-zsh.sh" \
    --backup-id=20000101-000000 >/dev/null
[ "$(grep -Fxc '# >>> Void Experience Zsh >>>' "$rollback_home/.zshrc")" -eq 1 ]
grep -Fqx 'include void-zsh-font.conf' \
    "$rollback_home/.config/kitty/kitty.conf"
HOME="$rollback_home" \
ZDOTDIR="$rollback_home" \
XDG_CONFIG_HOME=/deliberately/wrong \
XDG_CACHE_HOME=/deliberately/wrong \
    zsh -ic 'alias ll >/dev/null; [[ "$STARSHIP_CONFIG" == "$HOME/.config/void-experience/zsh/starship.toml" ]]'

printf 'mutated-xfce\n' >"$rollback_home/.config/xfce4/value"
printf 'mutated-layout\n' >"$rollback_home/.local/bin/void-layout"
printf 'new-project-file\n' >"$rollback_home/.local/bin/void-preview"
printf 'post-install\n' >"$rollback_home/Desktop/post-install.txt"

HOME="$rollback_home" \
XDG_CURRENT_DESKTOP=XFCE \
XDG_SESSION_TYPE=x11 \
VOID_TEST_LOG="$test_log" \
PATH="$mock_dir:$PATH" \
    "$project_dir/scripts/rollback.sh" 20000101-000000 >/dev/null

grep -qx 'baseline-xfce' "$rollback_home/.config/xfce4/value"
grep -qx '# baseline-zsh' "$rollback_home/.zshrc"
grep -qx 'baseline-kitty' "$rollback_home/.config/kitty/kitty.conf"
grep -qx 'baseline-layout' "$rollback_home/.local/bin/void-layout"
grep -qx 'baseline-desktop' "$rollback_home/Desktop/user.txt"
[ ! -e "$rollback_home/.local/bin/void-preview" ]
[ ! -e "$rollback_home/Desktop/post-install.txt" ]
grep -Fq 'panel-load ' "$test_log"

selection_file="$test_root/selection"
VOID_EXPERIENCE_SELECTION_FILE="$selection_file" \
    "$project_dir/scripts/install-packages.sh" \
    --extras=ani-cli,void-zsh --dry-run >"$test_root/packages.out"
grep -qx 'ani-cli,void-zsh' "$selection_file"
grep -q ' ani-cli ' "$test_root/packages.out"
grep -q ' zsh starship zoxide ' "$test_root/packages.out"

if grep -q -- '-b remove,fullscreen,maximized_' \
    "$project_dir/scripts/void-layout.sh"; then
    echo "FAIL: layout helper passes more than two EWMH properties to wmctrl" >&2
    exit 1
fi
grep -q -- '-b remove,fullscreen' "$project_dir/scripts/void-layout.sh"
grep -q -- '-b remove,maximized_vert,maximized_horz' \
    "$project_dir/scripts/void-layout.sh"

echo "PASS: apply file tree is idempotent"
echo "PASS: primary monitor is configured first"
echo "PASS: one-monitor and two-monitor profiles differ correctly"
echo "PASS: Picom falls back from GLX to XRender"
echo "PASS: xfwm compositor is restored if both Picom backends fail"
echo "PASS: rollback restores baseline and displaces post-install files"
echo "PASS: Void Zsh is idempotent, backup-gated and rollback-safe"
echo "PASS: ani-cli and Void Zsh resolve through the optional selector"
echo "PASS: fullscreen and maximize states use separate valid wmctrl requests"
