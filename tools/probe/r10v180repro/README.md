# r10v180 — ADVERSARIAL VERIFICATION of r10uvm180 (§ cloneBodyBareTdAlias180)

VERDICT: ACCEPT.  Every headline number reproduced bit-for-bit from my own
worktrees and my own builds.  No pristine-right -> patched-wrong cell was found
on any legal SV I could write, so no fix was needed and the production surface is
the implementer's unchanged.

## Binaries (built here, frozen chmod 555 before any sweep)

```
pristine  32978f1be49b524fca38801f8a56ad50   /tmp/wt_v180pris at a clean 87074d42
patched   14a355f3b04a10e6313cd65e95e2c270   /tmp/wt_v180 = FRESH 87074d42 + git apply -3 of the patch
```

Both md5s equal the implementer's.  The patch applies clean on a fresh 87074d42
and rebuilds to the byte-identical binary.

## Gates re-run (my sweeps, SLANG_UHDM exported per binary)

| gate | result |
|---|---|
| goldens | 23 PASS / 0 FAIL on BOTH binaries; `SLANG_UHDM=/bin/false` -> 0 PASS / 23 FAIL |
| u2r tf+default | 679 CMP_EQUAL / 50 SLANG_REJECT / 2 SURELOG_FAIL on both binaries, both modes; ct8rows PASS vs the committed baseline AND vs my own pristine, both modes |
| surelog both modes | 1588 rows, identical histograms (937/567/48/19/10/3/2/1/1); ct8rows PASS baseline-vs-pristine, baseline-vs-patched and pristine-vs-patched.  NO ROW CONVERTED in either direction |
| cmds.txt audit | 6070 cmds.txt files across four sweep workdirs: 0 reference the main-tree binary or a worktree build; every slang line names the frozen path.  The 50 surelog cmds.txt with no slang line are exactly the 48 SURELOG_FAIL + 1 NO_UHDM + 1 TIMEOUT rows |
| byte movers | 4 / 956 surelog (SeqDriver x2, MiniAmiq x2), 0 / 1358 u2r |
| prediction | `predict180` over my PRISTINE surelog databases names exactly those four, 0 problems; over the 956 PATCHED and the 1358 u2r pristine databases it names 0 |
| mover attribution | order-blind workdir-normalised whole-dump diff = 23 changed lines per mover; lines naming neither one of the law's typedefs nor a structural line of their typespecs: 0 in all four |
| heads | SeqDriver x2 142->29, MiniAmiq x2 116->26, ONE head each; the other eight cmp logs BYTE-IDENTICAL (SimpleUVM 29, Scoreboard/def 95, BuildUVMPkg 52, Earlgrey 31/176, Rggen 0).  All eight moving cmp logs are byte-identical to the committed `head_pris_*` / `head_pat_*` artifacts |
| census | `ct180cen` SeqDriver/default: pristine agree=5033 differ=94, patched agree=5127 differ=0, key gaps unchanged (980/451); `cen180score` TOGOLD=94 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 |
| canaries | canaries.sh ok=52 changed=0 (sl) / ok=8 changed=0 (u2r); ctcan2 PASS x2; canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 |
| protected DBs | InterfaceModPort / BlackParrotComplex / YosysOldOr byte-identical both modes; SVSwitch 4842211c4030; YosysVerx 6ccda350c24a |
| wide boundary | my own `vbound180.sh`: LISTED=4940 FENCED_SKIPPED=0 PROCESSED=4940 ASYMMETRIC=0 NO_OUTPUT_PAIRS=380, PROCESSED-ASSERT-OK.  9880 rc cells compared side-by-side: ASYMMETRIC-RC=0, including all 16 segfault pairs (symmetric, pre-existing) |
| prior-pass arms | uvm178 + v178 + uvm173 + v173 + uvm169 + v169 = 38 arms x 2 views: all 76 official cmp logs BYTE-IDENTICAL between the two binaries |

## What I added that the pass did not do

* `vbound180.sh` compares the DATABASE BYTES as well as the dump, which is what the
  pass's own R5 says the dump gate cannot see.  Over the same tree: 38 byte-moved
  cells vs 34 dump-moved.  The four byte-only cells are `g180_c_home` and
  `g180_e_chain`, both views — exactly R5's claim, now measured on both instruments.
  Excluding my nine arms the dump-moved set is 18 cells, identical to the pass's.
* `vscore180.py` scores the DEF and the ELAB view SEPARATELY (see finding F1).
* nine new arms, run through the official cmp against a fresh Surelog golden in both views.

## Arms (this directory), official cmp lines pristine -> patched, def / elab

```
v180_a_share     def  112->0     elab  112->0   
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=11 KEYGAP-pris=49 KEYGAP-pat=49 cells=113
                   elab TOGOLD=13 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=66 KEYGAP-pris=27 KEYGAP-pat=27 cells=163
v180_b_faces     def 2495->2495  elab 2615->2615
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=39 KEYGAP-pris=96 KEYGAP-pat=96 cells=230
                   elab TOGOLD=14 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=149 KEYGAP-pris=2 KEYGAP-pat=2 cells=266
v180_c_three     def  112->112   elab  112->112 
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=1 AGREE-BOTH=20 KEYGAP-pris=74 KEYGAP-pat=74 cells=154
                   elab TOGOLD=20 AWAY=0 MOVED-WRONG=0 STILL-WRONG=12 AGREE-BOTH=96 KEYGAP-pris=20 KEYGAP-pat=20 cells=222
v180_d_chain     def  112->112   elab  112->0   
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=1 AGREE-BOTH=27 KEYGAP-pris=97 KEYGAP-pat=97 cells=211
                   elab TOGOLD=33 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=123 KEYGAP-pris=22 KEYGAP-pat=22 cells=274
v180_e_ret       def  112->0     elab  112->0   
                   def  TOGOLD=2 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=40 KEYGAP-pris=67 KEYGAP-pat=67 cells=171
                   elab TOGOLD=20 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=124 KEYGAP-pris=28 KEYGAP-pat=28 cells=238
v180_f_class     def  112->1110  elab 1234->1234
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=14 KEYGAP-pris=36 KEYGAP-pat=36 cells=82
                   elab TOGOLD=10 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=55 KEYGAP-pris=23 KEYGAP-pat=23 cells=122
v180_g_unit      def  112->17    elab  112->17  
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=8 KEYGAP-pris=10 KEYGAP-pat=10 cells=27
                   elab TOGOLD=4 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=26 KEYGAP-pris=6 KEYGAP-pat=6 cells=47
v180_h_qual      def  122->122   elab  122->122 
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=6 AGREE-BOTH=15 KEYGAP-pris=59 KEYGAP-pat=59 cells=133
                   elab TOGOLD=4 AWAY=0 MOVED-WRONG=6 STILL-WRONG=37 AGREE-BOTH=53 KEYGAP-pris=22 KEYGAP-pat=22 cells=180
v180_i_inst      def  112->0     elab  112->0   
                   def  TOGOLD=0 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=8 KEYGAP-pris=10 KEYGAP-pat=10 cells=27
                   elab TOGOLD=4 AWAY=0 MOVED-WRONG=0 STILL-WRONG=0 AGREE-BOTH=26 KEYGAP-pris=6 KEYGAP-pat=6 cells=47
```

Four arms become EQUAL to golden in both views (`v180_a_share`, `v180_e_ret`,
`v180_i_inst`, and `v180_d_chain` in elab).  **AWAY = 0 and MOVED-WRONG = 0 in
every one of the 18 arm-views above and in all 22 arm-views of the pass's own
boundary movers re-scored per view** — 40 arm-views in total, one exception (F2).

## Findings

### F1 — the pass's arm scorer merges the DEF and ELAB views (measurement, not production)

`grid180.sh` does `cat cen.g.def.txt cen.g.elab.txt > cen.g.txt`, and `score180.py`
keys its dict on the PATH column alone (`d[parts[1]] = parts[2]`), not on the view
tag.  A def row and an elab row with the same path therefore COLLIDE and the last
writer — the elab row — wins, which is RESUME.md §9's "a last-writer dict drops
rows".  The committed "15 arms x 2 views: TOGOLD 94, AWAY 0, MOVED-WRONG 0" is an
ELAB-only score for every colliding key.  `vscore180.py` here scores the views
separately.  **The verdict does not change**: AWAY=0 per view on all 40 arm-views.
The official per-view cmp counts in the pass's `cmds.txt` were never merged, so the
acceptance evidence itself was sound.

### F2 — a typedef OF a typedef moves from one wrong value to another (judge-invisible)

`v180_h_qual.sv`, elab view, 6 cells:
```
Anvil_imp/function@10:3/.../logic_var@19:25   gold=logic_typespec[rivet_t -> -]
                                              was =logic_typespec[rivet_t -> Anvil_pk::rivet_t]
                                              now =logic_typespec[rivet_t -> rivet_t]
```
Golden gives the clone's `flange_t` (= `typedef rivet_t flange_t`) resolved
`logic_typespec` NO `Typedef_alias` at all; we give it one either way, so both
values are wrong and neither is closer.  The arm's official cmp logs are
**byte-identical on the two binaries in both views** (122 lines, same head), so the
judge does not see it.  It is a residue, but it falsifies the unqualified
"MOVED-WRONG 0" claim: the right statement is "MOVED-WRONG 0 except the
typedef-of-a-typedef cell, which the judge does not read".

### F3 — new residue: an importer's OWN body is bare in golden too

`v180_d_chain.sv`, DEF view, `Chn_b::shard_b`'s cast `pebble_t'(s)` at 30:31 —
`Chn_b` wildcard-imports `Chn_c`, and this is `Chn_b`'s OWN subroutine, not a clone:
```
Chn_b/function@20:3/.../func_call@30:22/operation@30:31
   gold=logic_typespec[pebble_t -> pebble_t]   both=logic_typespec[pebble_t -> Chn_c::pebble_t]
```
Golden is bare there and both binaries are qualified.  It is one step outside
FENCE 1 and it is why `v180_d_chain` clears in ELAB (112 -> 0) but holds at 112 in
DEF.  Adjacent to R1 (the explicit-import clone) and a candidate for the next
widening; `v180_d_chain.sv` is the ready witness.

### F4 — two arms' cmp LINE COUNTS GROW, and neither is a regression

`g180_d_class`/def 112 -> 590 and my `v180_f_class`/def 112 -> 1110.  In both the
pass's own head cleared and unmasked a PRE-EXISTING `vpiAutomatic` gap on a class
method, which prints the whole `function` object:
```
g180_d_class  vpiAutomatic count  golden 7   pristine 6   patched 6
v180_f_class  vpiAutomatic count  golden 6   pristine 5   patched 5
```
Identical on both binaries, and the class world itself is untouched (`Shuttle_c`
prints 105 identical dump lines on both).  RESUME.md §9: masks cascade, the count
is a lower bound and is not comparable across a change that removes a mask.  The
pass's boundary table says "none regressed", which is true, but a reader will trip
over the growth; it is recorded here.

### F5 — `g180_e_chain`'s two cmp logs differ in an object id only

def and elab both: two lines, `logic_typespec: (marl_lt), id:650` vs `id:658`, same
head, same count.  A serialization-order artifact of the extra minted copy; ids are
not read by any generated `Compare`.

## What did NOT move

* the HOME body, including where the source spells the typedef EXPLICITLY QUALIFIED
  (`Anvil_pk::rivet_t` in `v180_h_qual.sv`): every `Anvil_pk/...` cell is
  byte-identical between the two binaries, and golden's home cells stay qualified.
* the class world (FENCE 2): `v180_f_class.sv` puts a class handle, a class method
  call and a class property read beside plain block locals; `Shuttle_c` is identical.
* the return variable (FENCE 3): `v180_e_ret.sv` scores AWAY=0 across six return
  shapes (same-typedef return, other-typedef return, a task, a void function, an
  enum-typedef return, an empty body), and `g169_a_import` / `v169_i_multi` — the
  two witnesses the fence was measured on — have byte-identical cmp logs.
* the goldens 23 (23/0 on both binaries) and every canary.  `RefPkgParamInEnum`
  carries no row in either committed baseline or in `tests/golden/` today
  (r10earl34repro's verifier README records this); the goldens plus ct8rows are its
  standing substitute and both are green.  No name is written by this pass — only a
  link is re-pointed, clone-gated — so the uniform-requalification dead end is not
  approached.

## Files

| file | what |
|---|---|
| `v180_a_share.sv` | the home and the clone in ONE design, same typedef, every role on both sides |
| `v180_b_faces.sv` | logic/bit/byte/int/integer/shortint/longint vs enum vs packed struct vs union vs a class handle, in a clone |
| `v180_c_three.sv` | one home, THREE importers (two wildcard, one explicit) plus a package that spells it itself |
| `v180_d_chain.sv` | A imports B imports C (a clone of a clone), a diamond and a shadow |
| `v180_e_ret.sv` | FENCE 3 under pressure: six return shapes |
| `v180_f_class.sv` | FENCE 2 under pressure: class handle, method call and property read in a clone body |
| `v180_g_unit.sv` | $unit, module and package typedefs of the same shape at once |
| `v180_h_qual.sv` | the spelling control: an explicitly qualified spelling in home and clone, plus a typedef of a typedef |
| `v180_i_inst.sv` | the same clone reached through three module instances |
| `vgrid180.sh` | grid180.sh with the DEF and ELAB views kept separate |
| `vscore180.py` | the per-view three-way arm scorer (F1) |
| `vbound180.sh` | the wide boundary with DATABASE-BYTE comparison as well as the dump (R5), parallel, rc recorded per side |
