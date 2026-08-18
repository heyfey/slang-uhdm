# r10v97 — the adversarial verification of r10uvm97, and the re-cut it needed

**MEASUREMENT-ONLY.** Nothing here is an acceptance judge; `uhdm-cmp`
(`~/.local/bin/uhdm-cmp`) and `scripts/verify_golden.py` are. **LHS is ALWAYS
golden (Surelog); RHS is ALWAYS ours.** slang was NOT patched, `results/*.csv`
were READ ONLY, nothing was promoted, **no corpus row converted**.

**VERDICT: ACCEPT WITH FIX.** Full transcript in `VERIFY.r10uvm97.txt`.

## What the verifier found

The shipped `/tmp/r10uvm97.patch` **turns a PASSING database into a failing one
on legal SystemVerilog**, judged by the official `uhdm-cmp`, in **both** views:

| arm | pristine | implementer's patch |
|---|---|---|
| `v97_c1_mixedgroup.sv` def / elab | **PASS_CMP** | CMP_FAIL, 1 head, 17 lines |
| `v97_c4_specparams.sv` def / elab | **PASS_CMP** | CMP_FAIL, 1 head, 17 lines |

The head (`head_c1_patched_def.cmp`) is the exact MIRROR of the one the pass
removes — `RHS: <null>` on `typespec::Compare`'s `Typedef_alias`, where **golden
HAS the alias and we no longer do**.

### Why

`drainClassNestedTdGroups54` groups on the TARGET class; a member is a
`(declaring class, typedef name)` pair. The shipped gate deduped members on
`(generic declaring class, name)` and **dropped** every duplicate before the
alias loop. That is right when the duplicated declaration IS the group's base —
Surelog compiles a parameterized class once, so golden's single object carries
no alias, which is the pass's whole point. It is **wrong** when the duplicated
declaration is a **non-base member**: a real cross-class group whose clone
member is a parameterized class with N live specializations. Golden still has
ONE object for that declaration and **it is aliased**; we have N copies and
nothing says which of them the class's `vpiTypedef` LISTING and its use sites
read. In `v97_c1` the copy that survived the dedup was the **unreachable** one
and the **LISTED** one lost its alias (and its span reverted from the base's
`10:13-10:20` to its own `15:13-15:20`).

## The re-cut

> **§ `classNestedTdDupCopiesFollowTheirDeclaration97v`.** The duplicate
> identity decides ONLY (a) how many members the group really has and (b)
> whether a member is a copy of the BASE's own declaration.
>
> * count **DISTINCT** `(declKey, name)` pairs; `< 2` ⇒ the group is one
>   declaration wearing N specializations — skip it entirely (this is
>   r10uvm97's head fix, unchanged);
> * inside the alias loop skip only the members that share the **BASE's**
>   `(declKey, name)`;
> * every copy of every OTHER declaration is aliased exactly as pass 54 did.

Six lines of code in the same block. After it: **BROKE 0 in all 30 arm runs**,
`c1`/`c4` back to PASS_CMP, and every one of the pass's own wins preserved
(`g97_a1` FIXED 1, `g97_a4` FIXED 2, `a2`/`a3`/`a5` unmoved).

## What reproduced bit-for-bit

Both of the implementer's binaries rebuilt to the **same md5s**
(`52288f8c…`, `06be7ee0…`), and every headline number reproduced: goldens 23/0
and 0/23; u2r 679/50/2 both modes with `ct8rows` PASS; surelog `--mode both`
with an identical histogram and **0 differing rows over 1588**; `byteverify`
u2r 0/1358 and surelog 9/956 — **exactly** the nine predicted from pristine
databases alone, each moving **7 dump lines ordered AND order-blind** (except
Scoreboard/default's coin: 127 / 7); census `same 5275 / DIFF 41 / 9 dbs` →
`5275 / 32 / 4`; heads 17 → 99,202 / 99,106 with 1 head; canaries `ok=56` /
`ok=9`, ctcan2 PASS ×2, canaudit `audited=33 UNCOVERED=0 FENCE-BREACH=0`; pins
`SAME=10 MOVED=0`. The **fixed** binary reproduces all of them, and 8 of its 9
mover databases are **byte-identical** to the implementer's.

## Two findings about the pass's own instruments

1. **`ct97cen`'s `SITE=ALIASED` rows can name UNREACHABLE objects.** They live
   in `Serializer::AllObjects` but not in the dump tree, so neither `uhdm-dump`
   nor `uhdm-cmp` ever sees them. Arm `v97_c3_twotd.sv` loses one such alias
   under the re-cut and its two whole dumps stay **byte-identical** (835 lines
   each, empty diff) while the census reports `FIXED 1`. A census cell on an
   `ALIASED` row is therefore **not** evidence of a judge-visible move.
2. **The pass's five arms all PASS `uhdm-cmp` on both binaries** — the object
   they move is unreachable there too. The law's only judge-visible evidence is
   the nine corpus databases, where R0's mis-bind makes the duplicate
   reachable.

## The boundary, wider than the pass's

`bound97.sh` carries `-path '*repro*'` and `-name '*.sv'`, contrary to the
"no path filter" claim in `GATES.r10uvm97.txt`; it never compiled the 59 `.v`
files or the non-repro `.sv` under `tools/probe`. The verifier re-ran from a
COPY of the whole tree, no filter, `.sv` **and** `.v`, **per file and per
directory**, both views, rc per cell:

```
PER-FILE  LISTED=3045 PROCESSED=3045 PROCESSED-ASSERT-OK
          RC_PAIRS_COMPARED=6090  RC_DIFF=0  ASYMMETRIC_OUTPUT=0  MOVED=12
PER-DIR   DIRS_LISTED=1476 EMPTY=104 PROCESSED=1372 PROCESSED-ASSERT-OK
          RC_DIFF=0  ASYM=0  MOVED=9
```

Every mover attributed; the three per-directory movers that are **not** the law
(`r10uvm75/76/88repro`) are proved a **coin**: the same pristine binary run four
times on one of those file sets gives four different dumps.

## Files

```
v97_c1_mixedgroup.sv   THE REGRESSION — a real group whose clone member is a
                       parameterized class with two specializations
v97_c4_specparams.sv   the same, with a foreign-specialized target so the
                       clone also carries Parameters/Param_assigns (both READ
                       by class_typespec::Compare)
v97_c2_dupbase.sv      the mirror: the duplicate set IS the base (must move)
v97_c3_twotd.sv        one class, two typedefs of one target, two specs
v97_c5_homes.sv        $unit / module / nested / interface / program homes
v97_c6_kinds.sv        every typedef shape in a generic class
v97_c7_usesites.sv     property/static/local/return/formal/cast/new/#()/extends/
                       static/virtual/extern-OOB
v97_c8_counts.sv       one, two and three live specializations in one database
v97_c9_pkganchor.sv    the package-anchored group (pass-50 law 4) crossed with
                       a parameterized declaring class
v97_ca_samename.sv     two same-named parameterized classes, one per module
armrun_v97.sh          three-way arm scorer (VIEW-GENERAL, SPAN-free,
                       file-free, SRCTEXT-free key; rc recorded)
bound_v97.sh           per-file wide boundary, no path filter, .sv AND .v
bounddir_v97.sh        per-directory boundary
GRID.pat / GRID.fix    the arm grids before and after the re-cut
BOUNDARY.fix / BOUNDARYDIR.fix   the two boundary transcripts
head_c1_patched_def.cmp          the regression head, verbatim
VERIFY.r10uvm97.txt              the full transcript
```
