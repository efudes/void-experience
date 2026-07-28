#!/usr/bin/env bash
set -euo pipefail

gap=8
dry_run=false
layout=""

if [[ ${1-} == "--dry-run" ]]; then
    dry_run=true
    layout=${2-}
elif [[ -n ${1-} ]]; then
    layout=$1
fi

for required in xdotool xwininfo xrandr xprop wmctrl rofi; do
    command -v "$required" >/dev/null 2>&1 || {
        printf 'Void Layout: missing command: %s\n' "$required" >&2
        exit 1
    }
done

window_id=$(xdotool getactivewindow)
window_hex=$(printf '0x%08x' "$window_id")

read -r window_x window_y window_width window_height < <(
    xwininfo -id "$window_id" |
        awk '
            /Absolute upper-left X:/ { x=$NF }
            /Absolute upper-left Y:/ { y=$NF }
            /^[[:space:]]*Width:/ { w=$NF }
            /^[[:space:]]*Height:/ { h=$NF }
            END { print x, y, w, h }
        '
)

window_cx=$((window_x + window_width / 2))
window_cy=$((window_y + window_height / 2))

monitor_found=false
monitor_name=""
monitor_x=0
monitor_y=0
monitor_width=0
monitor_height=0

while read -r output status geometry _rest; do
    [[ $status == connected ]] || continue
    if [[ $geometry =~ ^([0-9]+)x([0-9]+)([+-][0-9]+)([+-][0-9]+) ]]; then
        candidate_width=${BASH_REMATCH[1]}
        candidate_height=${BASH_REMATCH[2]}
        candidate_x=${BASH_REMATCH[3]}
        candidate_y=${BASH_REMATCH[4]}
        if (( window_cx >= candidate_x &&
              window_cx < candidate_x + candidate_width &&
              window_cy >= candidate_y &&
              window_cy < candidate_y + candidate_height )); then
            monitor_name=$output
            monitor_x=$candidate_x
            monitor_y=$candidate_y
            monitor_width=$candidate_width
            monitor_height=$candidate_height
            monitor_found=true
            break
        fi
    fi
done < <(xrandr --query)

if [[ $monitor_found != true ]]; then
    printf 'Void Layout: active window is not on a connected monitor.\n' >&2
    exit 1
fi

read -r work_x work_y work_width work_height < <(
    xprop -root _NET_WORKAREA |
        sed -E 's/^[^=]+=[[:space:]]*//; s/,/ /g' |
        awk '{ print $1, $2, $3, $4 }'
)

max() { (( $1 > $2 )) && printf '%s' "$1" || printf '%s' "$2"; }
min() { (( $1 < $2 )) && printf '%s' "$1" || printf '%s' "$2"; }

area_x=$(max "$monitor_x" "$work_x")
area_y=$(max "$monitor_y" "$work_y")
area_right=$(min "$((monitor_x + monitor_width))" "$((work_x + work_width))")
area_bottom=$(min "$((monitor_y + monitor_height))" "$((work_y + work_height))")
area_width=$((area_right - area_x))
area_height=$((area_bottom - area_y))

if [[ -z $layout ]]; then
    selection=$(
        printf '%s\n' \
            '▌  ПОЛОВИНА  ←' \
            '▐  ПОЛОВИНА  →' \
            '□  МАКСИМИЗИРОВАТЬ' \
            '▣  ВЕСЬ ЭКРАН · 8 PX' \
            '▎  ТРЕТЬ  ←' \
            '▕  ТРЕТЬ  →' \
            '▌  ДВЕ ТРЕТИ  ←' \
            '▐  ДВЕ ТРЕТИ  →' \
            '▌││  КОЛОНКА 1' \
            '│▌│  КОЛОНКА 2' \
            '││▐  КОЛОНКА 3' \
            '▛  ЧЕТВЕРТЬ  ↖' \
            '▜  ЧЕТВЕРТЬ  ↗' \
            '▙  ЧЕТВЕРТЬ  ↙' \
            '▟  ЧЕТВЕРТЬ  ↘' |
            rofi -dmenu -i -p 'Layout' \
                -theme-str '
                    window { width: 56%; }
                    listview { columns: 3; lines: 5; spacing: 8px; }
                    element { padding: 15px 10px; }
                    element-text {
                        horizontal-align: 0.5;
                        vertical-align: 0.5;
                    }
                '
    )
    case "$selection" in
        '▌  ПОЛОВИНА  ←') layout=half-left ;;
        '▐  ПОЛОВИНА  →') layout=half-right ;;
        '□  МАКСИМИЗИРОВАТЬ') layout=maximize ;;
        '▣  ВЕСЬ ЭКРАН · 8 PX') layout=fill-gapped ;;
        '▎  ТРЕТЬ  ←') layout=third-left ;;
        '▕  ТРЕТЬ  →') layout=third-right ;;
        '▌  ДВЕ ТРЕТИ  ←') layout=twothirds-left ;;
        '▐  ДВЕ ТРЕТИ  →') layout=twothirds-right ;;
        '▌││  КОЛОНКА 1') layout=column-left ;;
        '│▌│  КОЛОНКА 2') layout=column-center ;;
        '││▐  КОЛОНКА 3') layout=column-right ;;
        '▛  ЧЕТВЕРТЬ  ↖') layout=quarter-tl ;;
        '▜  ЧЕТВЕРТЬ  ↗') layout=quarter-tr ;;
        '▙  ЧЕТВЕРТЬ  ↙') layout=quarter-bl ;;
        '▟  ЧЕТВЕРТЬ  ↘') layout=quarter-br ;;
        *) exit 0 ;;
    esac
fi

[[ -n $layout ]] || exit 0

inner_x=$((area_x + gap))
inner_y=$((area_y + gap))
inner_width=$((area_width - 2 * gap))
inner_height=$((area_height - 2 * gap))

half_width=$(((inner_width - gap) / 2))
third_width=$(((inner_width - 2 * gap) / 3))
two_thirds_width=$((inner_width - gap - third_width))
half_height=$(((inner_height - gap) / 2))

target_x=$inner_x
target_y=$inner_y
target_width=$inner_width
target_height=$inner_height

case "$layout" in
    fill-gapped)
        # The default target is the complete work area inset by $gap.
        # It deliberately remains a normal window so xfwm/Picom keep borders,
        # shadows and rounded corners.
        ;;
    half-left)
        target_width=$half_width
        ;;
    half-right)
        target_x=$((inner_x + half_width + gap))
        target_width=$((inner_width - half_width - gap))
        ;;
    third-left)
        target_width=$third_width
        ;;
    twothirds-right)
        target_x=$((inner_x + third_width + gap))
        target_width=$two_thirds_width
        ;;
    twothirds-left)
        target_width=$two_thirds_width
        ;;
    third-right)
        target_x=$((inner_x + two_thirds_width + gap))
        target_width=$third_width
        ;;
    column-left)
        target_width=$third_width
        ;;
    column-center)
        target_x=$((inner_x + third_width + gap))
        target_width=$third_width
        ;;
    column-right)
        target_x=$((inner_x + 2 * (third_width + gap)))
        target_width=$((inner_x + inner_width - target_x))
        ;;
    quarter-tl)
        target_width=$half_width
        target_height=$half_height
        ;;
    quarter-tr)
        target_x=$((inner_x + half_width + gap))
        target_width=$((inner_width - half_width - gap))
        target_height=$half_height
        ;;
    quarter-bl)
        target_y=$((inner_y + half_height + gap))
        target_width=$half_width
        target_height=$((inner_height - half_height - gap))
        ;;
    quarter-br)
        target_x=$((inner_x + half_width + gap))
        target_y=$((inner_y + half_height + gap))
        target_width=$((inner_width - half_width - gap))
        target_height=$((inner_height - half_height - gap))
        ;;
    maximize)
        if [[ $dry_run == true ]]; then
            printf 'monitor=%s area=%d,%d %dx%d layout=maximize\n' \
                "$monitor_name" "$area_x" "$area_y" "$area_width" "$area_height"
            exit 0
        fi
        wmctrl -ir "$window_hex" \
            -b remove,fullscreen,maximized_vert,maximized_horz
        # xfwm4 processes EWMH state changes asynchronously. Wait until a
        # fullscreen client is restored before asking it to maximize again.
        for _attempt in {1..25}; do
            state=$(xprop -id "$window_id" _NET_WM_STATE 2>/dev/null || true)
            [[ $state != *'_NET_WM_STATE_FULLSCREEN'* &&
               $state != *'_NET_WM_STATE_MAXIMIZED_VERT'* &&
               $state != *'_NET_WM_STATE_MAXIMIZED_HORZ'* ]] && break
            sleep 0.02
        done
        wmctrl -ir "$window_hex" -b add,maximized_vert,maximized_horz
        exit 0
        ;;
    *)
        printf 'Void Layout: unknown layout: %s\n' "$layout" >&2
        exit 2
        ;;
esac

if [[ $dry_run == true ]]; then
    printf 'monitor=%s area=%d,%d %dx%d layout=%s target=%d,%d %dx%d\n' \
        "$monitor_name" "$area_x" "$area_y" "$area_width" "$area_height" \
        "$layout" "$target_x" "$target_y" "$target_width" "$target_height"
    exit 0
fi

# Geometry requests sent while xfwm4 still considers a window fullscreen or
# maximized are ignored. Restore it first and wait up to 500 ms for EWMH state
# and decorations to settle.
wmctrl -ir "$window_hex" \
    -b remove,fullscreen,maximized_vert,maximized_horz
for _attempt in {1..25}; do
    state=$(xprop -id "$window_id" _NET_WM_STATE 2>/dev/null || true)
    [[ $state != *'_NET_WM_STATE_FULLSCREEN'* &&
       $state != *'_NET_WM_STATE_MAXIMIZED_VERT'* &&
       $state != *'_NET_WM_STATE_MAXIMIZED_HORZ'* ]] && break
    sleep 0.02
done
sleep 0.02

read -r frame_left frame_right frame_top frame_bottom < <(
    xprop -id "$window_id" _NET_FRAME_EXTENTS 2>/dev/null |
        sed -E 's/^[^=]+=[[:space:]]*//; s/,/ /g' |
        awk '{ print $1+0, $2+0, $3+0, $4+0 }'
)

client_width=$((target_width - frame_left - frame_right))
client_height=$((target_height - frame_top - frame_bottom))
command_x=$((target_x + frame_left))
command_y=$((target_y + frame_top))
(( client_width > 0 && client_height > 0 )) || {
    printf 'Void Layout: target is too small for window decorations.\n' >&2
    exit 1
}

wmctrl -ir "$window_hex" \
    -e "0,$command_x,$command_y,$client_width,$client_height"

# xfwm4 may translate EWMH client coordinates according to frame gravity.
# Measure the resulting outer frame and make one correction pass. This keeps
# gaps symmetric across themes instead of hard-coding titlebar offsets.
sleep 0.06
read -r actual_client_x actual_client_y < <(
    xwininfo -id "$window_id" |
        awk '
            /Absolute upper-left X:/ { x=$NF }
            /Absolute upper-left Y:/ { y=$NF }
            END { print x, y }
        '
)
actual_outer_x=$((actual_client_x - frame_left))
actual_outer_y=$((actual_client_y - frame_top))
correction_x=$((target_x - actual_outer_x))
correction_y=$((target_y - actual_outer_y))

if (( correction_x != 0 || correction_y != 0 )); then
    wmctrl -ir "$window_hex" \
        -e "0,$((command_x + correction_x)),$((command_y + correction_y)),$client_width,$client_height"
fi
