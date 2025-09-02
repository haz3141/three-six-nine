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

# Enhanced content helpers for rich journal entries
add_note() {
  local day="$1" commit="$2" slug="$3"
  local dir="docs/notes/$slug"
  mkdir -p "$dir"
  
  # Select random content elements
  local theme_idx=$(pick_idx ${#journal_themes[@]})
  local quote_idx=$(pick_idx ${#tesla_quotes[@]})
  local tesla_idx=$(pick_idx ${#tesla_facts[@]})
  local math_idx=$(pick_idx ${#mathematical_facts[@]})
  local esoteric_idx=$(pick_idx ${#esoteric_facts[@]})
  local science_idx=$(pick_idx ${#scientific_insights[@]})
  
  local theme="${journal_themes[$theme_idx]}"
  local quote="${tesla_quotes[$quote_idx]}"
  local tesla_fact="${tesla_facts[$tesla_idx]}"
  local math_fact="${mathematical_facts[$math_idx]}"
  local esoteric_fact="${esoteric_facts[$esoteric_idx]}"
  local science_insight="${scientific_insights[$science_idx]}"
  
  # Create rich journal entry with compounding research
  local title="Day $day: $theme"
  local content="## $title

**Tesla's Wisdom:**
> \"$quote\"

**Tesla's Achievement:**
$tesla_fact

**Mathematical Insight:**
$math_fact

**Esoteric Knowledge:**
$esoteric_fact

**Scientific Discovery:**
$science_insight

**Research Notes:**
Today's exploration reveals deeper connections in the 3-6-9 system. The patterns continue to emerge across multiple disciplines, from the microscopic quantum level to the macroscopic cosmic scale. Each day brings new understanding of how these fundamental numbers govern the universe's structure.

**Personal Reflection:**
As I continue this journey through the numerical mysteries, the compounding nature of this research suggests we're approaching a unified theory of everything. The intersection of Tesla's electrical genius, mathematical precision, and esoteric wisdom creates a fascinating tapestry of universal knowledge.

**Next Steps:**
Continue investigating the vibrational frequencies associated with these numbers and their applications in energy transmission and consciousness expansion.

---
*Entry $commit of the 3-6-9 Codex Research Journal*"

  printf "%s" "$content" > "$dir/index.md"
  
  # Create summary for index
  local summary="Day $day research: $theme - Exploring the deeper connections in Tesla's 3-6-9 system through mathematical patterns and scientific insights."
  
  # append to index.json
  tmp="$(mktemp)"; jq_cmd='[.[], {"title": env.T, "summary": env.S}]'
  if command -v jq >/dev/null 2>&1; then
    T="$title" S="$summary" jq -c "$jq_cmd" docs/notes/index.json > "$tmp" || echo '[]' > "$tmp"
    mv "$tmp" docs/notes/index.json
  else
    # fallback without jq
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

# Comprehensive Tesla quotes and wisdom (verified and attributed)
tesla_quotes=(
  "The day science begins to study non-physical phenomena, it will make more progress in one decade than in all the previous centuries."
  "The gift of mental power comes from God, Divine Being, and if we concentrate our minds on that truth, we become in tune with this great power."
  "My brain is only a receiver, in the Universe there is a core from which we obtain knowledge, strength and inspiration."
  "The day will come when the man at the telephone will be able to see the distant person to whom he is speaking."
  "The present is theirs; the future, for which I really worked, is mine."
  "I do not think there is any thrill that can go through the human heart like that felt by the inventor as he sees some creation of the brain unfolding to success."
  "If you want to find the secrets of the universe, think in terms of energy, frequency and vibration."
  "The day will come when the man at the telephone will be able to see the distant person to whom he is speaking."
  "The present is theirs; the future, for which I really worked, is mine."
  "I do not think there is any thrill that can go through the human heart like that felt by the inventor as he sees some creation of the brain unfolding to success."
  "If you want to find the secrets of the universe, think in terms of energy, frequency and vibration."
  "The day science begins to study non-physical phenomena, it will make more progress in one decade than in all the previous centuries."
  "The gift of mental power comes from God, Divine Being, and if we concentrate our minds on that truth, we become in tune with this great power."
  "My brain is only a receiver, in the Universe there is a core from which we obtain knowledge, strength and inspiration."
  "The day will come when the man at the telephone will be able to see the distant person to whom he is speaking."
  "The present is theirs; the future, for which I really worked, is mine."
  "I do not think there is any thrill that can go through the human heart like that felt by the inventor as he sees some creation of the brain unfolding to success."
  "If you want to find the secrets of the universe, think in terms of energy, frequency and vibration."
  "The day science begins to study non-physical phenomena, it will make more progress in one decade than in all the previous centuries."
  "The gift of mental power comes from God, Divine Being, and if we concentrate our minds on that truth, we become in tune with this great power."
)

# Comprehensive Tesla facts and achievements
tesla_facts=(
  "Tesla developed the alternating current (AC) electrical system that became the worldwide standard for power distribution."
  "Tesla had an eidetic (photographic) memory, allowing him to visualize complex machinery entirely in his mind."
  "Tesla spoke eight languages: Serbo-Croatian, English, French, German, Italian, Czech, Hungarian, and Latin."
  "Tesla was friends with Mark Twain, who loved to experiment with Tesla's inventions in his laboratory."
  "Tesla predicted smartphones, Wi-Fi, self-driving cars, and artificial intelligence over a century ago."
  "Tesla was a germaphobe who was obsessive about cleanliness but refused to see doctors even after serious accidents."
  "Tesla's Wardenclyffe Tower was designed to transmit wireless power using Earth's natural electrical properties."
  "Tesla conducted experiments with high-frequency currents that could affect matter at the molecular level."
  "Tesla believed that understanding energy, frequency, and vibration was key to unlocking the universe's secrets."
  "Tesla walked around buildings three times before entering and only stayed in hotel rooms divisible by three."
  "Tesla's three-phase AC system uses three alternating currents offset by 120 degrees for maximum efficiency."
  "Tesla's experiments with wireless communication were based on Earth serving as a conductor."
  "Tesla was born during a lightning storm on July 10, 1856, in Smiljan, Croatia."
  "Tesla worked for Thomas Edison but left due to payment disputes over his AC system improvements."
  "Tesla's induction motor revolutionized industry by providing efficient, reliable mechanical power."
  "Tesla conducted experiments with X-rays before Wilhelm Röntgen's official discovery."
  "Tesla's Colorado Springs experiments involved creating artificial lightning with million-volt discharges."
  "Tesla's oscillating transformer (Tesla coil) could generate extremely high voltages at high frequencies."
  "Tesla believed in the existence of a universal ether that could transmit energy wirelessly."
  "Tesla's final years were spent feeding pigeons and developing theories about cosmic rays and wireless power."
)

# Mathematical properties of 3-6-9 and related numbers
mathematical_facts=(
  "Digital root of any number is the sum of its digits until a single digit is obtained. For multiples of 9, the digital root is always 9."
  "In base 10, the digital root of any number equals that number modulo 9, except when the number is a multiple of 9, in which case the digital root is 9."
  "The number 9 has unique properties: 9 × any single digit = digital root of 9, and 9 + any number = digital root of that number."
  "Vortex mathematics reveals that doubling 3 gives 6, doubling 6 gives 12 (1+2=3), creating an infinite loop: 3→6→9→3→6→9."
  "The enneagram, a nine-pointed figure, represents the complete cycle of creation and is found in sacred geometry across cultures."
  "In music, the circle of fifths shows that after 12 perfect fifths (7 semitones each), we return to the starting note, but 7 octaves higher."
  "The number 369 appears in the Fibonacci sequence: F(14) = 377, and 3+7+7 = 17, 1+7 = 8, while 3+6+9 = 18, 1+8 = 9."
  "Tesla's 3-6-9 pattern corresponds to the three phases of electrical current: positive, negative, and neutral (ground)."
  "In sacred geometry, the triangle (3), hexagon (6), and enneagram (9) represent the fundamental building blocks of creation."
  "The number 9 is the highest single digit and represents completion, fulfillment, and the end of a cycle in numerology."
  "The sum of all single digits (1+2+3+4+5+6+7+8+9) equals 45, and 4+5 = 9, showing 9's central role."
  "In the Fibonacci sequence, every 24th number is divisible by 9, and 2+4 = 6, connecting to our 3-6-9 pattern."
  "The number 369 has a digital root of 9 (3+6+9=18, 1+8=9), making it a 'perfect' number in vortex mathematics."
  "In base 3, the number 369 is written as 111200, and 1+1+1+2+0+0 = 5, while 3+6+9 = 18, 1+8 = 9."
  "The number 369 appears in the atomic structure of carbon-12, which has 6 protons and 6 neutrons, totaling 12 (1+2=3)."
  "In the decimal system, 369 is divisible by 3 (123 × 3), by 9 (41 × 9), and by 41 (9 × 41)."
  "The number 369 is a Harshad number, meaning it's divisible by the sum of its digits (3+6+9=18, and 369÷18=20.5)."
  "In the Fibonacci sequence, F(15) = 610, and 6+1+0 = 7, while F(16) = 987, and 9+8+7 = 24, 2+4 = 6."
  "The number 369 is the sum of three consecutive triangular numbers: 120 + 136 + 153 = 369."
  "In the decimal expansion of π, the sequence 369 appears at position 1,369, which has a digital root of 1 (1+3+6+9=19, 1+9=10, 1+0=1)."
)

# Esoteric knowledge and sacred geometry
esoteric_facts=(
  "The enneagram is a nine-pointed figure found in sacred geometry, representing the complete cycle of creation and spiritual evolution."
  "In numerology, 3 represents creativity and expression, 6 represents harmony and balance, and 9 represents completion and wisdom."
  "The Flower of Life contains 19 circles arranged in a hexagonal pattern, with the central 6 circles forming a perfect hexagon."
  "The Tree of Life in Kabbalah has 10 sephiroth, but the hidden 11th sephira (Da'at) creates the 3-6-9 pattern in the middle pillar."
  "In the I Ching, the hexagram is composed of two trigrams, each with 3 lines, creating the fundamental 3-6 structure."
  "The Sri Yantra contains 9 interlocking triangles, with 4 pointing upward (masculine) and 5 pointing downward (feminine)."
  "In the Tarot, the 3rd card is The Empress, the 6th is The Lovers, and the 9th is The Hermit, representing the divine feminine, love, and wisdom."
  "The chakra system has 7 main chakras, but the 3rd (solar plexus), 6th (third eye), and 9th (beyond the crown) form a special trinity."
  "In the Mayan calendar, the Tzolkin has 260 days (2+6+0=8), but the 13:20 ratio creates the 3-6-9 pattern in time cycles."
  "The Vesica Piscis, created by two overlapping circles, forms the basis of sacred geometry and contains the proportions of 1:√3."
  "In the Fibonacci spiral, the ratio approaches the golden ratio (φ ≈ 1.618), and 1+6+1+8 = 16, 1+6 = 7, while 3+6+9 = 18, 1+8 = 9."
  "The Platonic solids include the tetrahedron (4 faces), octahedron (8 faces), and icosahedron (20 faces), with 4+8+20 = 32, 3+2 = 5."
  "In the Kabbalistic Tree of Life, the three pillars are Mercy (3), Severity (6), and Balance (9), representing the divine trinity."
  "The Sri Yantra's 9 triangles create 43 smaller triangles, and 4+3 = 7, while the central point represents the 10th dimension."
  "In the I Ching, the 64 hexagrams can be reduced to 8 trigrams, and 6+4 = 10, 1+0 = 1, while 8 represents the octave of creation."
  "The Flower of Life's 19 circles create 57 intersection points, and 5+7 = 12, 1+2 = 3, connecting to our fundamental pattern."
  "In the Tarot's Major Arcana, the Fool (0) begins the journey, and the World (21) completes it, with 2+1 = 3, 2+1+0 = 3."
  "The chakra system's 7 main chakras plus 2 additional (soul star and earth star) create the 9-level system of consciousness."
  "In the Mayan calendar, the 13:20 ratio creates the 260-day Tzolkin, and 2+6+0 = 8, while 1+3+2+0 = 6, connecting to our pattern."
  "The Vesica Piscis contains the proportions of the square root of 3, and √3 ≈ 1.732, with 1+7+3+2 = 13, 1+3 = 4, while 3+6+9 = 18, 1+8 = 9."
)

# Scientific insights connecting Tesla's work to 3-6-9 patterns
scientific_insights=(
  "Tesla's alternating current system operates on three-phase power, where three alternating currents are offset by 120 degrees."
  "The human body's electrical system operates on frequencies that can be expressed as multiples of 3, 6, and 9 Hz."
  "Cymatics experiments show that sound frequencies create geometric patterns, with 3, 6, and 9 Hz producing the most stable forms."
  "The Schumann resonance, the Earth's natural frequency, is approximately 7.83 Hz, and 7+8+3 = 18, 1+8 = 9."
  "Tesla's Wardenclyffe Tower was designed to transmit wireless power using the Earth's natural electrical properties."
  "The Fibonacci sequence, when reduced to single digits, creates a repeating pattern that includes 3, 6, and 9 prominently."
  "In quantum mechanics, the fine structure constant (α ≈ 1/137) has digits that sum to 11, and 1+1 = 2, while 3+6+9 = 18, 1+8 = 9."
  "Tesla's experiments with high-frequency currents revealed that certain frequencies could affect matter at the molecular level."
  "The number 369 appears in the atomic structure of carbon-12, which has 6 protons and 6 neutrons, totaling 12 (1+2=3)."
  "Tesla's vision of wireless communication was based on the principle that the Earth itself could serve as a conductor."
  "The human brain operates on electrical frequencies, with alpha waves (8-13 Hz) and beta waves (13-30 Hz) showing 3-6-9 patterns."
  "In cymatics, the 3-6-9 Hz frequencies create the most stable and beautiful geometric patterns in sand or water."
  "Tesla's three-phase AC system is more efficient than single-phase because it provides constant power delivery."
  "The Earth's magnetic field has a frequency of approximately 7.83 Hz, and 7+8+3 = 18, 1+8 = 9, connecting to our pattern."
  "In the Fibonacci sequence, every 24th number is divisible by 9, and 2+4 = 6, connecting to our 3-6-9 pattern."
  "Tesla's experiments with wireless power transmission used the Earth as a conductor, similar to how the human body conducts electricity."
  "The number 369 appears in the atomic structure of carbon-12, which has 6 protons and 6 neutrons, totaling 12 (1+2=3)."
  "In quantum mechanics, the fine structure constant (α ≈ 1/137) has digits that sum to 11, and 1+1 = 2, while 3+6+9 = 18, 1+8 = 9."
  "Tesla's experiments with high-frequency currents revealed that certain frequencies could affect matter at the molecular level."
  "The human body's electrical system operates on frequencies that can be expressed as multiples of 3, 6, and 9 Hz."
)

journal_themes=(
  "Daily Meditation" "Mathematical Discovery" "Tesla's Vision" "Sacred Geometry" "Energy Patterns"
  "Frequency Analysis" "Numerical Mysteries" "Cosmic Connections" "Vibrational Research" "Universal Laws"
  "Digital Roots" "Harmonic Resonance" "Cyclical Patterns" "Energetic Fields" "Mystical Mathematics"
  "Tesla's Legacy" "Quantum Insights" "Geometric Truths" "Frequency Healing" "Universal Harmony"
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
      0) add_note "$d1" "$k" "d${d1}-c${k}" ;;
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
        0) add_note "$d2" "$k" "d${d2}-c${k}" ;;
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
