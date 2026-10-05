# v11u245 — adversarial verification of r11u245

Verifier of pass 245 (the module/type ground: the `$unit` typedef writer and LAW S for `$unit` typedefs), base
`9666f384`, worktrees `/tmp/wt_v11u245` (law + fixes), `/tmp/wt_v11u245pris` (pristine), `/tmp/wt_v11u245fix` (the fix
build). Verdict: **the implementer's numbers reproduce; two law defects found by fresh cases are fixed behind
`R11V245_*` switches** (src/R245.h, UhdmExporter, inside § unitTdLawS245). Delivery: `/tmp/r11u245.verified.patch`.

## Binaries (`evidence/binaries.txt`)

| binary | md5 |
|---|---|
| pristine (9666f384) | `0c5bd3be423a452b5cac3b1c1c45aaec`, equal to the main tree's build |
| law (r11u245.patch on fresh 9666f384) | `9f15dba2596966f23c4610d81e740f10`, equal to the implementer's |
| fix (law + the refinements below) | `47788291f72d7ef494a6e1bab4d85c83` |

All link slang 12.0.0+545f88b2e and were frozen (`chmod 555`) before any measurement. Every cmds.txt of the three
sweeps names its own binary: 3265 rows each, the other 50 kept rows carry no slang line (`evidence/cmds_audit.txt`,
`drivers/cmdsaudit.sh`, the path list filtered by `$FENCED` first).

## Reproduction of the implementer's headline numbers

* Gate sweeps (`tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u245_w{P,L,F}`, `evidence/sweep_summary.txt`):
  * pristine: probe 3498 + 589, surelog 470/10 + 466/8, uhdm2rtlil 803 + 0 per mode, downstream 803/66/2/0, 0 changes;
  * law: the same, apart from one probe change `v11u108repro/brk/f5/b07_param_typedef_arr` differ:file(9) ->
    differ:file(7); every other csv row of all four csvs equal to pristine's (workdir paths stripped).
* Byte movers law vs pristine: corpus 0 / 2560 (`byteverify.sh`, SELFCHECK 2559 / 2560 flagged, mirrors built by
  `drivers/bvmirror.sh` from a fence-filtered path list), probe and downstream lanes 1 / 4892 (b07, predicted).
* Predictor (`drivers/predict.py`, the implementer's, rerun on my pristine sweep): the same 22 names
  (`evidence/predict_law.txt`).
* The implementer's 28 case directories (`evidence/grid_r11u245cases.txt`, 56 case-views): 38 enter STRICT_EQUAL;
  law + `R11U245_OFF` gives pristine bytes on 56 of 56; rc 4 only on UA a02 / a06 on every binary.
* Canaries on the fix sweep: `canaries.sh` surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog
  ok=58 (EXPECT_UNKNOWN=1 PASS), uhdm2rtlil ok=2 (EXPECT_UNKNOWN=6 PASS).
* Determinism (`evidence/determinism_fix.txt`, `drivers/det.sh`): three concurrent draws of the FIX binary on
  Earlgrey_0_1 and the five UVM rows read one hash per row-mode on 11 of 11 runnable row-modes, each equal to the fix
  sweep's (Scoreboard testflags writes no database on any binary).

## What the attack found

### 1. The probe change b07 is a regression wearing a shrink (fixed: § unitLawSSkipAliasedListing245v)

The implementer reported `b07_param_typedef_arr` file(9) -> file(7) as a shrink on the same first record. The first
record is the same (#4), but the WALK diverges earlier: pristine's walk diverges at #170, the law's at #44
(`uhdm-strictcmp --max 20`; the objects count 328 -> 398 against golden's 368). The cause: `typedef e_t [3:0] arr_t;`
(a packed array of a `$unit` typedef) is listed with its own element reference (the listing's `vpiElemTypespec`
`arr_t` over the multi-clone chain); § unitTdLawS245's aliased copy of that listing stacked a second level, so the
definition net reads `arr_t -> arr_t -> chain` where golden and pristine read `arr_t -> chain`. Both the flat and the
chain-keyed away census read 0 lost on it (the records re-expand unchanged one level deeper; the census sees no loss
for an inserted layer), so only the walk position shows it. Fresh case K/k02 (a body variable and a wire of the same
shape) shows the same: pristine's walk diverges at #171 (a pre-existing face, the elaborated wire written as a
logic_var), the law's at #8.

**§ unitLawSSkipAliasedListing245v** (`R11V245_ALIASEDLIST_OFF`; UhdmExporter, § unitTdLawS245's set): a `$unit` listing
that already carries a Typedef_alias or (logic) an element reference is left out of the set. b07 and K/k01, k02
return to pristine's bytes.

### 2. Elaborated generate-scope variables got the subroutine copy (fixed: § unitLawSGenVarIsInstVar245v)

§ unitTdLawS245 treats a variable whose parent is not a module / interface / program instance as a subroutine local
(aliased copy, no vpiInstance). An elaborated variable inside a generate scope (`if (1) begin : g nib_t v; end`,
`work@top.g.v` under `gen_scope work@top.g`) fell into that branch. Golden binds a bare, unaliased copy of a ranged
typedef there (its own object, golden id 65 vs the listing id 9, no Typedef_alias) and the listing for an unranged
one, exactly the instance-scope variable rule. Pristine bound the listing (uhdm-cmp fails at the design: the copy's
identity); the law bound the aliased copy (uhdm-cmp fails at the alias, 17 lines).

**§ unitLawSGenVarIsInstVar245v** (`R11V245_GENVAR_OFF`; UhdmExporter, § unitTdLawS245's variable branch): a variable
under a gen_scope follows the instance-scope rule. Cases V/v02, G/g01, g03, g05 (both views, 8 case-views) go from
stage 1 on pristine and law to judge-equal (STRICT_NOTEQUAL line: the remaining record is the listing located at the
first use inside the generate block, 6:5 where golden has 3:9, the same on pristine: residue 2).

One refinement was tried and dropped before the fix sweep: an elaborated `wire nib_t w` (V/v01) reads the typedef's
aliased per-instance clone where golden binds the plain typespec; the dump ids show that clone is pristine's own
(pristine id 41 -> alias -> listing), the law does not write it, so it is a residue, not a law break.

## Grid (fresh cases)

48 case directories, both views, 96 case-views (`cases/{V,P,A,G,K,H}`, every case's first line names its law):

| group | shape | law |
|---|---|---|
| V v01-v21 | `$unit` vector / bit typedefs on wires, generate, named-block, interface + modport, struct member, two instances, program, two files, `$unit` class, unpacked array var, task formals, type parameter, localparam, alias of alias, function return, initializer, interface port | § unitTdLawS245, § unitTdRetVarAtTypeToken245 |
| P p01-p14 | int / string / int unsigned / byte / longint / integer / shortint signed / integer unsigned / shortreal / real / time typedefs in generate, interface port, struct member, child ports, function return and task local, macro body, alias-of-alias | § unitPredefTd245, § unitPredefAliasOfAlias245, § unitRealTdElabShares245 |
| A a01-a06 | fixed arrays: ranged memory, descending range, localparam size, 2-D, port, size form in two instances | § unitArrTd245 |
| G g01-g05 | generate-scope variables (if, for, case, string in a child) | § unitLawSGenVarIsInstVar245v |
| K k01-k04 | packed array of a `$unit` typedef: type parameter default, body var + wire, function, struct member | § unitLawSSkipAliasedListing245v |
| H h01-h03 | included header, CRLF file, two files with the same declarator column | § unitPredefTd245, § unitTdRetVarAtTypeToken245, § unitTdLawS245 |

* `evidence/grid.txt` (864 lines, pristine / law / law + `R11U245_OFF` / law + each of the six switches; every line
  carries `rc=`), `evidence/gridsum.txt`: law + `R11U245_OFF` == pristine on 96 of 96; 82 case-views move; **40 enter
  STRICT_EQUAL, none leaves**; each switch reverts only its own cases (UNITLAWS 72, UNITPREDEF 32, UNITARR 12,
  UNITRETLOC 8, UNITPREDEFAOA 2, UNITREALTD 2). rc 4 only on pristine, under `R11U245_OFF` and under the listing
  writers' own switches.
* `evidence/gridfix.txt` (480 lines: fix, fix + `R11V245_OFF`, fix + `R11U245_OFF`, fix + each R11V switch),
  `evidence/fixsum.txt`: fix + `R11V245_OFF` == law on 96 of 96; fix + `R11U245_OFF` == pristine on 96 of 96; 12
  case-views move against the law (8 by GENVAR into judge-equality, 4 by ALIASEDLIST back to pristine's bytes); none
  leaves STRICT_EQUAL.
* The implementer's 56 case-views on the fix: 38 STRICT_EQUAL as on the law; fix + `R11V245_OFF` == law on 56 of 56;
  the fix moves only US/u15 (both views, a generate-scope variable, still stage 1 on the definition-view generate face).
* Downstream on the 48 cases (`evidence/dscase_{pristine,law,fix}.txt`, `evidence/dscase_table.txt`, the harness's own
  `one`): pristine 35 IDENTICAL / 4 EQUIVALENT / 5 DIVERGENT / 4 STATUS_DIFF; law and fix 39 / 4 / 3 / 2 with the same
  verdict on every case. No case leaves IDENTICAL. a01, a02, a03, a05 enter IDENTICAL. A06 goes DIVERGENT ->
  STATUS_DIFF (residue 1).
* Away census on the cases (`drivers/chainaway.py`, chain-keyed, records from `strictcmp_s1` so a stage-1 pristine is
  walked too): pristine -> fix 0 lost and 1120 toward. Law -> fix and its swapped positive control both read 0 / 0:
  the census cannot see an inserted alias layer (finding 1), so the walk position is the instrument there.

## The fix sweep (`/tmp/v11u245_wF`)

* probe EQUAL 3498 + STRICT_NOTEQUAL 589, regressions=0 conversions=0 **changes=0** (b07 back to differ:file(9));
  surelog and uhdm2rtlil regressions=0 conversions=0 changes=0; downstream 803 IDENTICAL / 66 SLANG_REJECT /
  2 EQUIVALENT / 0 DIVERGENT, not identical and not excused 0.
* Every csv row of all four csvs equal to the pristine sweep's (workdir paths stripped).
* Byte movers: fix vs pristine 0 / 2560 corpus and 0 / 4892 probe + downstream; fix vs law 0 / 2560 corpus and 1 / 4892
  (b07). The frozen predictor `drivers/predict_fix.py` (md5 `9665eb0fb2253a64928e859b5d0f196d`, output
  `evidence/predict_fix.txt` md5 `4b89229e54c3634d7b35e0fbc0679752`, read from the law sweep's databases of the 22
  r11u245 names, fail-closed on `$FENCED`) named 6 databases. b07 moved as predicted. arrays03 (3 databases) and
  Scr1SvTests (2, a known failure) did not move: no rebound binder there.
* No corpus row and no probe case changes status or strict detail against the base. **No conversion.**

## Residues, ranked

1. **Bit-element arrays** (A/a06 `typedef bit [1:0] pr_t [4]`). § unitArrTd245's listing reuses the class builder
   (TypeEmit `buildUnpackedArrayTypedefTs` -> `anonAggregateElemTs`), which mints a `logic_typespec` for every
   integral element; golden writes `bit_typespec`. Stage 1 on law and fix. Downstream goes DIVERGENT (pristine, which
   exits 4) -> STATUS_DIFF (law: uhdm2rtlil READ_FAIL, `Could not find wire 't' for bit select`). It is the same
   builder for class- and module-scope typedefs, a ground-B fix for the next pass.
2. **The `$unit` vector listing located at its first use inside a generate block** (G g01, g03, g05, V v02: 6:5 where
   golden has 3:9; the same on pristine).
3. **An elaborated wire of a `$unit` ranged typedef** (V/v01) binds pristine's aliased per-instance clone where golden
   binds the plain typespec (STRICT_NOTEQUAL type, #52; the law improves the row from stage 1). The same re-point the
   variable branch does would apply to nets; not written.
4. **The elaborated wire of a packed array of a typedef written as a logic_var** (K/k02 #171, pristine too), and the
   function-formal shape K/k03 (stage 1, unchanged).
5. The implementer's residues stand: ports of an unranged `$unit` typedef (US/u11, ModuleEmit port sharing); UA a02,
   a04, a05, a06; the parameter typed by a `$unit` typedef (ParamEmit, ground A); c04's package alias listing
   (ParamEmit `emitPackage`, ground A); `realtime` variables (ModuleEmit); the definition-view generate statements
   (US/u15, P/p01); a 2-D `$unit` array (A/a04: the elaborated fold reads only one range) and a localparam-sized one
   (A/a03, stage 1).
6. Brief items (1)(a), (b), (e), (2)-(6) were not attempted by the implementer.

## Process

* Every driver reads `$FENCED` fail-closed from the FENCED= line of `tools/probe/r11u107repro/canaudit.sh`
  (`drivers/env.sh`); `predict_fix.py`, `cmdsaudit.sh`, `bvmirror.sh`, `chainaway.py`, `away.py` and the compiled
  `strictcmp_s1` refuse to run without it. No corpus source was read, and no corpus row was run outside the gate
  sweeps and det.sh's fixed list. One audit loop ran once with `$FENCED` unset in its shell: its filter
  (`grep -vwE ""`) dropped every path, so nothing was opened. It was rerun with the variable set.
* The first sweep (law) read the worktree's `build/uhdm-strictcmp` (md5 equal to the main tree's); later sweeps pin
  `STRICT_CMP` to the frozen copy. Fix builds ran in `/tmp/wt_v11u245fix` so the running sweep's tools were never
  relinked.
* Every tool call through a variable was guarded with `[ -x ]`. No patch file is kept in this directory.
