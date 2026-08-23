# r10v104 — adversarial verification of r10uvm104 (§ macroPasteDotText104)

## VERDICT: **ACCEPT WITH FIX**

Every headline number in the implementer's report reproduced bit-for-bit from
the verifier's own worktrees, builds and sweeps — including the two binary
md5s.  The decoded law is correct and the head really clears.

The **fence is not** correct.  The report claims "a macro **with arguments**
always bails, because after formal substitution the definition text no longer
describes the value".  It does not.  The bail depends on the *actual argument
text* differing from the *formal's name*, which is a coincidence, not a fence.
Invoke the implementer's own arm-4 macros with argument identifiers that happen
to match their formals — legal SystemVerilog — and the as-shipped model
rewrites characters golden leaves alone:

| macro (as written in `g104_a4_args.sv` / verifier `v2`) | invocation | golden | pristine | as-shipped |
|---|---|---|---|---|
| `` `define PAIR(A,B) `"A``(``B``)`" `` | `` `PAIR(A,B) `` | `A(B)` | `A(B)` | **`A.B)`** |
| `` `define AA(V,I) `"aa(``V``,``I``)`" `` | `` `AA(V,I) `` | `aa(V,I)` | `aa(V,I)` | **`aa(.,.)`** |
| `` `define SEP(a,b) `"a``-``b`" `` | `` `SEP(a,b) `` | `a-b` | `a-b` | **`a.b`** |
| `` `define TAG3(x) `"x``-``tail`" `` | `` `TAG3(x) `` | `x-tail` | `x-tail` | **`x.tail`** |

36 + 12 cells AWAY-FROM-GOLDEN per view, on slots that were **right** before the
patch.  `grid104.sh`'s count-only verdict cannot see the `TAG3` case at all: arm
`v13` has 24 unmatched string cells before AND after, so it reads "SAME" while
one cell went to golden and another went away.  The verifier's `score104.py`
classifies **per value** and names both halves.

The fix (production, minimal, in `surelogPasteDotString`): read the enclosing
`` `define `` out of the buffer — assert it really encloses the `` `" `` (every
newline between them is a line continuation), take the macro name, and **bail if
a `(` follows it immediately**, i.e. if the macro carries a formal list.  Nothing
else in the model changes.

## What golden actually does with formals (measured, arm `v13`, both views)

`PreprocessFile::evaluateMacro_` substitutes the formals and consumes the pastes
that touch one *before* `enterString`'s regex runs
(`../Surelog/src/SourceCompile/PreprocessFile.cpp:919`), so:

| body | window touches a formal? | golden |
|---|---|---|
| `` `"pre``-``post_``x`" `` (`TAG(zz)`) | no | `pre.post_zz` — **dotted** |
| `` `"``-``x`" `` (`TAG2(zz)`) | yes | `-zz` — not dotted |
| `` `"x``-``tail`" `` (`TAG3(zz)`) | yes | `zz-tail` — not dotted |
| `` `"lead``-``x``-``tail`" `` (`TAG4(zz)`) | both windows | `lead-zz-tail` — not dotted |

So the accurate model is *per window*, not per macro.  The fix is deliberately
**conservative**: it bails on the whole argument-bearing macro, which reproduces
the pristine rendering exactly and therefore cannot regress anything.  The one
shape it gives up — a window inside an argument-bearing macro touching no formal
— is **R-args** below; no corpus source has it, and pristine was wrong there too.

## What survived the attack

Fourteen arms, 28 arm/view cells, `.sv` and `.v`, `def` and `-elabuhdm`,
golden-vs-pristine-vs-under-test, scored on the WHOLE path-normalised dump as
well as on the string multiset, rc recorded for all three tools per cell.  See
`GRID.v104.txt` for the table.  Paste counts 0..4; separators `- _ . : / , * +`,
space, TAB, letters, digits, `$ ! % & < = Z`; `` ``` `` at the start, middle and
end; runs of 4/5/6 backticks; macro nesting 1..3 deep and a stringification
reached through three wrapper macros; `` `ifdef ``/`` `ifndef `` with a paste
window in BOTH branches (the taken branch's text is the one rewritten — the
`getFullyOriginalLoc` walk lands correctly); `` `\`" `` escaped quotes in four
positions; identifier pastes outside a string; a plain literal beside a
stringification in one macro body; `$unit`, package, module and class; parameter,
localparam, assignment Rhs, `$display`, `$sformatf`, case item, concatenation;
three instances; expansions that themselves contain the separator (the
two-walk agreement test bails, it never mis-anchors); empty macro references; an
arg-less stringification invoked from inside an arg-bearing macro (fires, and
correctly); a multi-line `` `define `` (bails, same as pristine).

With the fix, **AWAY = 0** on every arm and view except the empty-macro slots of
`v10`, which were wrong in pristine too (golden renders an empty macro reference
inside a stringification as the literal token `@@EMPTY_MACRO@@`, e.g.
`@@EMPTY_MACRO@@.11`; pristine `-11`, ours `.11`) — a wrong-to-differently-wrong
slot, not a regression.

## Gates and boundary

`GATES.v104.txt` (all five gates, both binaries, every number re-measured) and
`BOUNDARY.v104.txt` (both halves of the wide boundary, from a COPY of
`tools/probe` with no path filter).

The verified binary produces databases **byte-identical to the as-shipped one**
across all 956 surelog and 1358 uhdm2rtlil databases: the fence costs nothing on
the corpus, and the head still goes 64 → 60 in both modes.

## Instruments

* `vgrid104.sh` — three-way arm grid, WHOLE-dump + string score, rc per cell.
* `score104.py` — per-VALUE TO-GOLDEN / AWAY-NEW-WRONG / AWAY-LOST-GOOD / STILL.
* `vcen104.py` — per-SLOT census (owner kind + owner span + dump DEPTH + field;
  payload = the Compare-visible value text; Counter multiset join).  A slot that
  matched golden before and does not after is AWAY even when totals balance.
* `vbound104.sh` — the wide boundary, PER-FILE and PER-DIRECTORY in one driver,
  list on fd 3, children `</dev/null`, PROCESSED asserted, scratch keyed on the
  RELATIVE path, rc per cell, and **both** the unsorted and the ORDER-BLIND
  (sorted) diff per cell, which separates the ordering coins from real movers
  without a re-run.
* `attr104.sh` — order-blind per-database attribution, partial-dump safe.
* `v*.sv` — the fourteen arms.
