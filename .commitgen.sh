#!/usr/bin/env bash
set -euo pipefail

START_DAYS_AGO="${START_DAYS_AGO:-369}"
DAYS="${DAYS:-369}"
TZ_REGION="${TZ_REGION:-America/New_York}"

# Capture system "now" once in the desired timezone (for consistent offsets)
if date -v -1d >/dev/null 2>&1; then
  # macOS/BSD
  NOW_DATE="$(TZ="$TZ_REGION" date +%Y-%m-%d)"
else
  # GNU
  NOW_DATE="$(TZ="$TZ_REGION" date +%Y-%m-%d)"
fi

# Up to 9 per-day slots (randomly picked)
SLOTS=("10:07:00" "11:44:00" "12:33:00" "14:07:00" "15:44:00" "16:33:00" "18:07:00" "19:44:00" "20:33:00")

rand() { echo $(( RANDOM )); }                    # simple, fast RNG
pick_idx() { local n="$1"; echo $(( $(rand) % n )); }

is_macos() { date -v -1d >/dev/null 2>&1; }
ts_at() { # ts_at <days_ago> <HH:MM:SS>
  local d="$1" t="$2"
  if is_macos; then
    TZ="$TZ_REGION" date -j -f "%Y-%m-%d %H:%M:%S" "$(TZ="$TZ_REGION" date -v -"${d}"d -j -f "%Y-%m-%d" "$NOW_DATE" +%Y-%m-%d) $t" "+%a %b %d %T %Y %z"
  else
    TZ="$TZ_REGION" date -d "$d days ago $t" "+%a %b %d %T %Y %z"
  fi
}

# Content helpers (tiny, real diffs)
add_note() {
  local title="$1" summary="$2" slug="$3"
  local dir="docs/notes/$slug"
  mkdir -p "$dir"
  printf "# %s\n\n%s\n" "$title" "$summary" > "$dir/index.md"
  # append to index.json (no python)
  tmp="$(mktemp)"; jq_cmd='[.[], {"title": env.T, "summary": env.S}]'
  if command -v jq >/dev/null 2>&1; then
    T="$title" S="$summary" jq -c "$jq_cmd" docs/notes/index.json > "$tmp" || echo '[]' > "$tmp"
    mv "$tmp" docs/notes/index.json
  else
    # fallback without jq: very small, safe adder
    if [ ! -s docs/notes/index.json ]; then echo "[]" > docs/notes/index.json; fi
    awk -v t="$title" -v s="$summary" '
      BEGIN{found=0}
      {buf=buf $0 ORS}
      END{
        if (buf ~ /\[\]/) {
          print "[{\"title\":\"" t "\",\"summary\":\"" s "\"}]"
        } else {
          sub(/\]$/, ",{\"title\":\"" t "\",\"summary\":\"" s "\"}]", buf)
          printf "%s", buf
        }
      }' docs/notes/index.json > "$tmp"
    mv "$tmp" docs/notes/index.json
  fi
}

tweak_css() {
  local css="docs/styles.css"
  local gap=$((8 + ( $(pick_idx 4) * 2 ) ))   # 8,10,12,14
  local rad=$((4 + ( $(pick_idx 4) * 2 ) ))   # 4,6,8,10
  perl -0777 -pe "s/(--gap:)\d+px;/\${1}${gap}px;/g" -i "$css"
  perl -0777 -pe "s/(--radius:)\d+px;/\${1}${rad}px;/g" -i "$css"
}

bump_log() {
  mkdir -p docs/src/daily
  echo "$1" >> docs/src/daily/changes.log
}

adjust_grid_dim() {
  local css="docs/styles.css"
  if (( $(pick_idx 2) == 0 )); then
    local cols=$((21 + $(pick_idx 3) )) # 21..23
    perl -0777 -pe "s/(--c:)\d+;/\${1}${cols};/g" -i "$css"
  else
    local rows=$((9 + $(pick_idx 2) ))  # 9..10
    perl -0777 -pe "s/(--r:)\d+;/\${1}${rows};/g" -i "$css"
  fi
}

commit_when() {
  local when="$1" msg="$2"
  git add -A
  if ! git diff --staged --quiet; then
    GIT_AUTHOR_DATE="$when" GIT_COMMITTER_DATE="$when" git commit -m "$msg"
  fi
}

# Knowledge seeds (bite-sized 3-6-9 material)
titles=(
  "Triad Patterns" "Hexadic Bridges" "Ennead Closure"
  "Tesla 3-6-9 Lore" "Digital Roots & 9" "Vortex Math Teaser"
  "Harmonics: 3rds & 6ths" "Polygonal Symmetry" "Cycle Ritual by 3s"
)
summaries=(
  "Exploring multiples of three as a base rhythm in simple grids."
  "Six as the connective tissue between triads and enneads."
  "Nine as a closure set in repeating digit sums and cycles."
  "Collected references and commentary around the 3-6-9 meme."
  "Why sums of digits mod 9 loop back into 9-centric behavior."
  "A glimpse into digit cycles and modular residues."
  "Stacking thirds and sixths within simple harmonic series."
  "Triangles, hexagons, enneagrams as recurring forms."
  "Practice: count by threes to 99 and observe residues."
)

# Iterate in 2-day clusters, each pair summing to 9 commits
d="$START_DAYS_AGO"
end_limit=$(( START_DAYS_AGO - DAYS + 1 ))
while (( d >= end_limit )); do
  d1="$d"; d2=$((d-1))
  a=$((1 + $(pick_idx 9))) # 1..9 on day1
  b=$((9 - a))             # remaining on day2

  # If we reached the end and only one day is left, push them all into day1
  if (( d2 < end_limit )); then b=0; fi

  # day1
  for ((k=1;k<=a;k++)); do
    slot="${SLOTS[$(pick_idx ${#SLOTS[@]})]}"
    when="$(ts_at "$d1" "$slot")"
    # Always make a change before committing
    i=$(pick_idx 4)
    case "$i" in
      0) j=$(pick_idx ${#titles[@]}); add_note "${titles[$j]}" "${summaries[$j]}" "d${d1}-c${k}" ;;
      1) tweak_css ;;
      2) bump_log "d=$d1 c=$k @ $when" ;;
      3) adjust_grid_dim ;;
    esac
    commit_when "$when" "$( [ $k -eq 1 ] && echo feat || echo chore ): day $d1 update (c=$k of $a)"
  done

  # day2
  if (( b > 0 )); then
    for ((k=1;k<=b;k++)); do
      slot="${SLOTS[$(pick_idx ${#SLOTS[@]})]}"
      when="$(ts_at "$d2" "$slot")"
      # Always make a change before committing
      i=$(pick_idx 4)
      case "$i" in
        0) j=$(pick_idx ${#titles[@]}); add_note "${titles[$j]}" "${summaries[$j]}" "d${d2}-c${k}" ;;
        1) tweak_css ;;
        2) bump_log "d=$d2 c=$k @ $when" ;;
        3) adjust_grid_dim ;;
      esac
      commit_when "$when" "$( [ $k -eq 1 ] && echo feat || echo chore ): day $d2 update (c=$k of $b)"
    done
  fi

  d=$((d-2))
done

echo "[✓] Generated clustered history without pushing. When ready, add remote and push."
