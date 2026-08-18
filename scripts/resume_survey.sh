#!/usr/bin/env bash
# resume_survey.sh — print the LIVE state of the convergence campaign so that a
# new operator (any model, any time) can pick up exactly where the last one
# stopped.  Read-only: it never builds, sweeps, or edits anything.
#
#   bash scripts/resume_survey.sh            # summary
#   HEADS=1 bash scripts/resume_survey.sh    # also run rowheads.sh on the newest control (minutes)
#
# Sections: git state, in-flight worktrees/patches, controls, baseline table,
# last landings + their declared next heads (R0), heartbeat/sentinel state.
set -u
cd "$(dirname "$0")/.." || exit 1
R=$PWD
hr(){ printf '\n== %s\n' "$*"; }

hr "GIT (branch, HEAD, dirtiness — a dirty tree usually means an integration was in flight)"
git rev-parse --abbrev-ref HEAD; git log -1 --format='%h %ad %s' --date=iso | cut -c1-160
echo "-- tracked modifications (should be EMPTY between integrations):"
git status --short | grep -v '^??' || echo "   (none)"
echo "-- untracked (locbug/ and __pycache__/ are known; anything else was left by an agent — inspect, then remove if empty):"
git status --short | grep '^??' | grep -v 'locbug/\|__pycache__' || echo "   (none)"

hr "LANDINGS: last 24h = $(git log --since='24 hours ago' --oneline | wc -l), last 7d = $(git log --since='7 days ago' --oneline | wc -l)"
git log -6 --format='%h %ad %s' --date=format:'%m-%d %H:%M' | cut -c1-150

hr "IN-FLIGHT PASSES (git worktrees; wt_r10<pass> = implementer, wt_v<pass>*/wt_vbuvm* = verifier)"
git worktree list | grep -v " $R " || echo "   (none)"

hr "PATCHES IN /tmp (LANDED = tools/probe/r10<pass>repro exists in HEAD; UNLANDED = in flight or awaiting integration)"
for p in /tmp/r10*.patch; do [ -f "$p" ] || continue; b=$(basename "$p"); echo "$b" | grep -Eq '^r10[a-z]+[0-9]+(\.verified)?\.patch$' || continue; pass=${b%%.*}; pass=${pass#r10}
  if git ls-tree -d HEAD tools/probe/r10${pass}repro >/dev/null 2>&1 && [ -n "$(git ls-tree -d HEAD tools/probe/r10${pass}repro)" ]; then st=LANDED; else st=UNLANDED; fi
  printf '   %s  %-8s  %s\n' "$(date -d @$(stat -c %Y "$p") +'%m-%d %H:%M')" "$st" "$p"; done 2>/dev/null | sort | grep UNLANDED
echo "   (LANDED patches omitted; a <pass>.verified.patch supersedes <pass>.patch; earl23 is QUARANTINED — never integrate it;"
echo "    an UNLANDED verified patch whose implementer+verifier worktrees are gone is READY TO INTEGRATE via RESUME.md §6)"

hr "CONTROLS in /tmp (pristine sweeps of the current HEAD; regenerate if absent — see RESUME.md §2)"
ls -d /tmp/ctl_wd_sl_* /tmp/ctl_wd_u2r_* /tmp/ctl_*.csv /tmp/pris_*.bin 2>/dev/null | sed 's/^/   /' || echo "   (none)"
for d in /tmp/ctl_wd_sl_*; do [ -d "$d" ] && echo "   $(basename $d): $(find $d -name slang.uhdm | wc -l) DBs"; done 2>/dev/null

hr "BASELINE (official, from committed results/*.csv)"
python3 scripts/accounting.py --md 2>/dev/null | head -6
echo "-- surelog NE rows now:"
grep CMP_NOTEQUAL results/golden_surelog.csv | cut -d, -f1,2 | tr '\n' ' '; echo
echo "   (UnsignedParam/HierPathEval/FileLocalParam/TopParam are slang-fenced: OUT OF SCOPE)"

hr "NEXT HEADS declared by the last landing per family (R0 lines in commit bodies)"
for fam in 'UVM pass' 'BuildUVMPkg pass' 'Earlgrey pass' 'Rggen pass'; do
  c=$(git log --format=%h -50 --grep="$fam" | head -1); [ -z "$c" ] && continue
  echo "-- $fam: $c $(git log -1 --format=%s $c | cut -c1-110)"
  git log -1 --format=%b $c | grep -iE 'R0|new head|next pass' | head -3 | cut -c1-220 | sed 's/^/     /'
done

hr "HEARTBEAT / SENTINEL (Claude-session artefacts; ignore if you are not that operator)"
[ -f /tmp/sentinel_pid.txt ] && { p=$(cat /tmp/sentinel_pid.txt); ps -o pid,etime,cmd -p $p 2>/dev/null | tail -1 | cut -c1-80 || echo "   sentinel pid $p not running"; }
[ -f /tmp/sentinel_deadman.log ] && tail -2 /tmp/sentinel_deadman.log | sed 's/^/   /'
echo "-- sweeps running now: $(ps -eo cmd | grep '[v]erify_golden.py' | grep -v grep | wc -l) (never rebuild build/slang-uhdm while >0)"

if [ "${HEADS:-0}" = "1" ]; then
  W=$(ls -dt /tmp/ctl_wd_sl_* 2>/dev/null | head -1)
  if [ -n "$W" ]; then
    hr "HEADS on $W (official uhdm-cmp; line count = head-object DEPTH, not distance)"
    bash tools/probe/r10uvm67repro/rowheads.sh $W /tmp/resume_survey_heads SeqDriver SimpleUVM Scoreboard MiniAmiq BuildUVMPkg Earlgrey_0_1 Rggen 2>&1 | grep -v SKIP | tail -14
  fi
fi

hr "NEXT: read RESUME.md §4-§9, then either finish/discard the in-flight integration, integrate any completed unlanded (verified) patch through §6, and refill empty slots from the R0 lines above."
