#!/usr/bin/env bash
# r10svs9/census.sh — how many PARENS-LESS event controls over a DOTTED path
# exist in each corpus, and in which tests.  Spelled as a source-text census
# because the law is a SYNTAX law: `@ <hierarchical_identifier>` with no
# parentheses.  Both corpora, every extension the harnesses feed.
#
# NOTE: plain `grep` here is ugrep; `-F` is used for any mid-pattern `$`.
# The pattern deliberately does NOT try to be a parser: it over-collects (it
# will match `@` inside a string or a comment) and the caller is expected to
# eyeball the hits, which is why every hit is printed with its file and line.
set -u
# ROOTS: THE UVM ROOT IS NOT OPTIONAL.  This script's FIRST version listed only
# the three test roots and MISSED $HOME/git-repos/Surelog/third_party/UVM, which
# every UVM-compiling test pulls in.  That omission made this pass predict 2
# surelog byte movers where GATE 5 found 9; the seven it missed are all ONE line
# of the UVM library (uvm_config_db.svh:289 `@waiter.trigger;`).  A census is
# only as good as the roots it names, so the roots are named here in full and the
# omission is recorded rather than quietly patched.
ROOTS=${ROOTS:-"$HOME/git-repos/Surelog/tests $HOME/git-repos/Surelog/third_party/tests $HOME/git-repos/Surelog/third_party/UVM $HOME/git-repos/uhdm2rtlil/test"}
PAT='@[[:space:]]*[A-Za-z_\\][A-Za-z_0-9$]*[[:space:]]*\.'
for R in $ROOTS; do
    [ -d "$R" ] || { echo "SKIP (absent): $R"; continue; }
    echo "=== $R"
    grep -rnE --include='*.sv' --include='*.v' --include='*.svh' --include='*.vh' \
         "$PAT" "$R" 2>/dev/null |
      grep -vE '@[[:space:]]*\(' |
      grep -vE '^[^:]+:[0-9]+:[[:space:]]*(//|\*)' |
      grep -vE '@[[:space:]]*[A-Za-z_][A-Za-z_0-9$]*[[:space:]]*\.[A-Za-z_0-9$]*[[:space:]]*\(' |
      tee /dev/stderr | wc -l
done
