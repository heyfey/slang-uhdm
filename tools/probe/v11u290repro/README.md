# v11u290 — adversarial verification of r11u290 (the two un-parked Surelog rows)

Base 309b62bc.  Implementer's patch /tmp/r11u290.patch (ten laws behind
`src/R290.h`, tools/probe/r11u290repro).  Verified patch
/tmp/r11u290.verified.patch = the implementer's patch plus five refinements
behind `r11v290On` in `src/R290.h` (each `R11V290_<NAME>_OFF`; `R11V290_OFF`
drops all five and gives the law's bytes; `R11U290_OFF` still drops every law
and refinement and gives pristine's bytes), this directory and the
regenerated tests/LAWS.md.

**VERDICT: the target holds; FIVE production refinements.**  The four target
row-modes convert on the law and on the fix, with every gate number
reproduced bit for bit.  Fresh cases found the law moving records away from
golden on legal SystemVerilog where pristine was right: 23 case-views, chain
away 2 to 8, all in the override-copy family (laws 4, 5 and 10).  They are
fixed behind their own switches, and the law-1 last-writer order is
corrected.  On the fix, chain away is 0 on all 202 grid movers.  No gate
database moves between the law and the fix.

## Target rows (fresh csv rows, law sweep and fix sweep identical)

    LogicTypespec,default,CMP_EQUAL,,,equal       (base STRICT_NOTEQUAL differ:endline(3))
    LogicTypespec,testflags,CMP_EQUAL,,,equal     (base STRICT_NOTEQUAL differ:endline(3))
    Scr1SvTests,default,CMP_EQUAL,,,equal         (base STRICT_NOTEQUAL differ:type(1))
    Scr1SvTests,testflags,CMP_EQUAL,,,equal       (base STRICT_NOTEQUAL differ:type(1))

The base heads, reproduced with build/uhdm-strictcmp:
- LogicTypespec: #14 endline (golden `my_package::typedef_logic_typespec`
  2:9-7:44, ours 2:9-2:20), #104 name, #105 depth.
- Scr1SvTests default: #48892 type (golden ref_obj `SCR1_MEM_CMD_RD`
  `work@scr1_pipe_ifu.SCR1_MEM_CMD_RD` scr1_pipe_ifu.sv 607:26-41, ours
  constant 1'b0).

uhdm-strictcmp on the law and fix databases reads STRICT_EQUAL 122 / 32 /
84098 / 83997 objects, and uhdm-cmp reads 0 lines on all four
(evidence/strict_targets.txt).  results/ is untouched.

## Binaries (frozen before any measurement; evidence/binaries_md5.txt)

| binary | md5 | note |
|---|---|---|
| pristine | f285f238dbd51f0029dc79812e56e69d | equal to the brief's base build |
| law | 29c6811344ecce47f41b66ca720c0bd5 | equal to the implementer's law8 |
| fix | 2aeed421790b4ced4ef55162b3008232 | final; every fix number below is from it |

The drafts fix1 377f8ed5, fixA 50d919c1, fixA2 bb617459 and fixB 2cc73f1b
are superseded.  Every one links slang 12.0.0+545f88b2e.

## Gates (tests/sweep.sh --jobs 3, workdirs of equal name length; evidence/sweeps.txt)

| stage | pristine (wdQ) | law (wdL) | fix (wdH) |
|---|---|---|---|
| probe | 3903 + 184, reg 0 | 3903 + 184, reg 0 conv 0 chg 0 | same |
| surelog | 478 + 2 / 472 + 2, reg 0 | 480 / 474, **reg 0 conv 4 chg 0** | same |
| uhdm2rtlil | 803/1/67 both modes, reg 0 | same, reg 0 conv 0 chg 0 | same |
| downstream | 803 / 66 / 2 / 0 | same, csv row-identical | same |

The law sweep exits 1 on the law-index check alone, because this directory's
cases were not yet indexed in the law tree.  The fix sweep exits 0.

Row diffs (evidence/csv_rowdiff_pristine_law.txt): pristine against law
differs only in the four conversions and in the LowMemLib/LowMemPkg
testflags detail text, which holds the workdir path.  Law against fix differs
in 0 lines in all four csvs, once the workdir names are normalized.

The first pristine sweep (wdP) was discarded.  A nohup launch that looked
dead ran concurrently with its relaunch in the same workdir and produced one
HARNESS_ERROR line.  Every number here is from the clean rerun, wdQ.

## Byte, census and away measurements

**byteverify** ran on fence-filtered mirrors (drivers/bvmirror.sh; 3365
databases, 8 fenced row-mode paths skipped by name).
- pristine → law: 4 movers, exactly the four targets.
- law → fix: 0 movers.
- pristine → fix: the same four.
- SELFCHECK reads 3363 of 3365, the known twin (pass 201's artefact).

**Probe bytes** (check_probe from one worktree path per pair;
evidence/probe_bytes.txt): pristine → law 0 of 4087, law → fix 0 of 4087.

**Firing census.** drivers/tracecensus.sh on fix1 and again on the final
binary, fence-filtered, each run before that binary's sweep.  Both are
byte-identical to r11u290's predict.txt: LogicTypespec d/t law 1, Scr1SvTests
d/t laws 2-10, nothing else.  No refinement tag fires on any gate database.
The prediction was 0 law → fix movers, and 0 moved (evidence/predict_fix.txt,
census_fix_final.txt).

**Away census on the four corpus movers** (drivers/awaycorp.sh +
awaychain.py; evidence/away_corpus.txt):
- order-blind lost 0, gained 5 / 78;
- chain away 0, toward 5, 5, 78, 78;
- positive control (binaries swapped): away 5, 5, 78, 78.

**Determinism** (drivers/det.sh: three concurrent draws per row-mode;
evidence/det_law.txt, det_fix.txt).  Scr1SvTests, LogicTypespec,
Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, BuildUVMPkg d/t and Scoreboard
d, Rggen d each read one hash, equal to the sweep's, for both the law and the
fix.  Scoreboard t and Rggen t write no database (rc 3 / rc 2, as in the
baseline).

**Canaries.**
- surelog: ok=50, changed=2 (the Scr1SvTests conversions).
- uhdm2rtlil: ok=16.
- ctcan2: surelog ok=58 PASS, uhdm2rtlil ok=2 PASS.

These hold for the law and for the fix.

**Binary-path audit:** in each sweep, 3273 of 3323 cmds.txt name that
sweep's own binary.  The other 50 carry no slang line.

## Reproduction of the implementer's grid (evidence/grid_implementer_reproduced_PL.txt, grid_final.txt)

The implementer's grid has 71 case dirs, 142 case-views.  With my binaries,
every line carries its exit code:
- 73 move and 47 enter STRICT_EQUAL; none leave and no exit code changes;
- R11U290_OFF gives pristine's bytes on 142 of 142;
- each mover restores to pristine under one switch: PKGTDPACKED 32,
  BASEIDXELEM 20, UNITENUMSHARE 18, MISEVALSHARE 1, and M/m03_tcm d/e under
  the miseval family together.

All of this matches the implementer's numbers.  The fix moves 0 of these 142
case-views against the law.

## Attack (cases/, 73 case dirs, 146 case-views, both views, every line with rc=)

Configurations: P, L, F, FV (R11V290_OFF), FU (R11U290_OFF), and the fix with
each of the 10 law switches and the 5 refinement switches off
(drivers/gridv.sh; evidence/grid_final.txt, grid_summary.txt,
grid_pairs.txt).

| family | law | what the grid varies |
|---|---|---|
| VT | 1 and § pkgTdPackedWriterKindOrder290v | the writer order: alphabetical against source order, two tops, program, interface and module mixes; a package net, a generate-block net, a function local, a port beside a net; signed and 2-D typedefs, a macro, two files, two packages |
| VE | 2 | the enum declared directly in the first file's $unit; a header included only by the first file; a parameterized child with an override; a child inside a for-generate; three files; a 2-bit enum; mixed local and $unit enums; a deep hierarchy; an enum-typed left side; a package-enum control |
| VH | 3 | a single non-top instance, a local index, a const-index left side beside the read, a parameter index, a nested index, a packed array, a comparison, an instance inside a generate block, a select as index, a trailing part select with and without an operation, a procedural control |
| VC | 4-10 | module, package and same-file $unit parameters in port part-select bounds; the m03 cross-file override shape with one port, two tcms, a plain bound, no port bound, the sibling parameter varied (none, unrelated, bare, inside $clog2, an operation, a nested operation, a header parameter, two siblings), body ranges against port ranges, a call against an operation |
| VM | 4 | the DMI ladder with two users, non-top, two instances, a range use top and non-top |

**Result on the fix:**
- pristine → fix: 129 moving, 71 entering STRICT_EQUAL, 0 leaving, 0
  exit-code changes;
- R11U290_OFF equals pristine on 146 of 146;
- R11V290_OFF equals the law on 146 of 146;
- each mover restores to pristine under one law switch: PKGTDPACKED 46,
  UNITENUMSHARE 18, BASEIDXELEM 18, CONNBOUNDCHAIN 6, MISEVALSHARE 5, OVFILE 2;
  the miseval family together restores the other 34, all VC/VM override-chain
  cases;
- law → fix: 33 moving, 14 entering STRICT_EQUAL.  Each restores to the law
  under one refinement switch (OVSIBOP 16, WRITERKIND 8, SHAREOPND 1) or a
  named pair (SHAREOPND + OVSIBOP on vc07, vc14, vc16 and vc17 default;
  SPLICEOPND + OVSIBOP on vc13 and vc21 d/e).

**Away census:**
- pristine → fix (evidence/away_final.txt): chain away 0 on all 202 grid
  movers of both grids, 1109 records toward golden.  Order-blind lost is 0
  except V/VM/vm02_nontop d (3), explained under Residues.
- law → fix (away_LF.txt): chain away 0 on all 33.
- positive control, binaries swapped on 26 sampled movers
  (away_poscontrol.txt): away on 23.

**Downstream** (drivers/dscases.py, multi-file aware; evidence/ds_final.txt,
ds_summary.txt).  On all 73 fresh case dirs no verdict is worse on the fix
than on pristine or the law: pristine IDENTICAL 53 / EQUIVALENT 19 /
DIVERGENT 1, the law and the fix 64 / 8 / 1.  Eleven dirs go EQUIVALENT →
IDENTICAL: ve01-ve07, vt01, vt02, vt17 and vt23.  vt15 is DIVERGENT on all
three binaries.

### The breaks (law against pristine on legal SV, pristine right; evidence/away_PL.txt)

| case-views | records | law | cause | refinement |
|---|---|---|---|---|
| vc05 d/e, vc06 d/e, vc10 d/e, vc11 d/e, vc14 d, vc07 d/e | chain away 2 (vc07 d: 8) | 5 OVCLONECHAIN | the override copy named through its own chain; golden keeps the parent's names unless a sibling reads the parameter as an operator operand | § ovCloneChainSiblingOperand290v |
| vc16 d/e, vc17 d/e, vc19 d | chain away 2-6 | 4 MISEVALSHARE | the sibling's Rhs shared into a CALL argument (`AW = $clog2(SIZE)`); golden lists its own copy there | § misevalShareOperandOnly290v |
| vc13 d/e, vc21 d/e | order-blind lost 2 (`<in>` names) | 10 OVSPLICETOP | the range copy hung at its source and twin-named; for an operator operand (`[SIZE/16384-1:0]`) golden keeps it in the bound | § ovSpliceTopOperandStaysHome290v |
| vc20 d/e, vc22 d/e | chain away 2 | 5 (via the twin) | as in the first row, seen through the § elabOvSpliceTopCopy290 twin | § ovCloneChainSiblingOperand290v |

On the fix: vc05, vc10, vc11, vc13, vc20 and vc22 reach STRICT_EQUAL in both
views.  vc06, vc07 and vc14 are stage 1 on every binary.  vc16, vc17 and vc19
are back at their pristine first field, file.  vc21 keeps one pristine-wrong
record (#370).

## Refinements (src/R290.h `r11v290On`; every function edited, for the integration overlap check)

1. **§ ovCloneChainSiblingOperand290v** (`R11V290_OVSIBOP_OFF`).
   - Rule: golden names the override road's copy of the parent's tree (the
     elaborated param_assign Rhs one instance down) through its OWN chain
     only when another parameter of that body reads the overridden parameter
     as an operand of an operator, through operators only.  That holds for
     `RW = SIZE/4` and `SIZE/4 + 1`, whether a localparam, a body parameter
     or a header parameter (vc09, vc12, vc15, vc18, Scr1's RAM_SIZE_WORDS).
   - Otherwise the copy keeps the names it was cloned with: no sibling,
     `1024/NB`, `RW = SIZE`, or `$clog2(SIZE)` (vc05, vc10, vc11, vc14, vc16,
     vc17).
   - The chain names are still computed (force 3) for the
     § elabOvSpliceTopCopy290 twins, which golden names through the chain.
   - Code: ParamEmit.cpp `emitParameters` (the predicate, beside
     `misevalOvRhs290()`); ExprEmit.cpp `emitExpr` NamedValue
     (§ elabMisevalRefSubst, the `noteMisevalSplice290` call); TypeEmit.cpp
     `drainMisevalSpliceChain290` (force 3 map, twin lookup).
2. **§ misevalShareOperandOnly290v** (`R11V290_SHAREOPND_OFF`).
   - Rule: § elabMisevalCompositeShares290 shares the sibling's Rhs only
     where it is a DIRECT OPERAND of an operator (the UHDM parent being built
     is an operation).  As a call argument, golden lists its own copy (vc16,
     vc17, vc19).
   - Code: ExprEmit.cpp `emitExpr` NamedValue (§ elabMisevalRefSubst).
3. **§ ovSpliceTopOperandStaysHome290v** (`R11V290_SPLICEOPND_OFF`).
   - Rule: § elabOvSpliceTopCopy290's copy hangs at its source and takes the
     source's names only for a call argument (`$clog2(SIZE)-1`; vc20, vc22,
     Scr1's addra).  As an operator operand (`SIZE/16384-1`, a body net
     vc13 or a port vc21), the copy stays in the bound, inside the typespec,
     re-stamped with the file, and is named through that chain.
   - Code: TypeEmit.cpp `emitSyntaxExpr` (the § elabOvMisevalNoFold branch).
4. **§ pkgTdPackedWriterKindOrder290v** (`R11V290_WRITERKIND_OFF`).
   - Rule: law 1's last writer is Surelog's.  UhdmWriter writes the
     programs, then the interfaces, then the modules (writeProgram,
     writeInterface and writeModule loops, each over a name-ordered map), so
     a module's net beats an interface's or a program's whatever their
     names.  The law took the alphabetically last definition of any kind.
   - Witnesses: vt09 (program zprog with module top) converts in both views;
     vt05, vt21 and vt22 move the typedef end to golden's
     (evidence/grid_final.txt; stage 1 on every binary on other faces).
   - Code: ModuleEmit.cpp `materializeDefNetTs` (law 1's span write).
5. **§ spliceChainSwitchOwnOnly290v** (`R11V290_SPLICESW_OFF`; switch
   semantics only, the default path unchanged).
   - Defect: `R11U290_SPLICECHAIN_OFF` returned early from the drain, which
     also dropped laws 5 and 7 and the law-10 twin naming.  Law 9 was
     therefore not droppable alone: in vc01, vc03 and vc04, SPLICECHAIN_OFF
     and CONNBOUNDCHAIN_OFF each restored pristine.
   - Fix: it now skips force-0 entries only.
   - Code: TypeEmit.cpp `drainMisevalSpliceChain290`.

## Byte controls (drivers/bytectl.sh; 2 batches, 85 earlier repro dirs, 3092 case dirs, 6184 case-views, three binaries)

The batches cover the mandated controls (r11u118repro, r11v11u118repro,
r11u119repro, r11u120repro, r11v120repro, r11u124/v124, r11u125, r11u131/v131)
plus r11u134/v11u134, r11u178/v178, r10scr13/14, r11u57, r10v66, r11u137 and
the 66 repro dirs whose README names the port-connection, hier-path-select or
unit/miseval parameter machinery.

| measure | result |
|---|---|
| exit-code differences | 0 |
| pristine → law | 6 movers, all toward golden (chain away 0) |
| law → fix | 0 movers |

The six pristine → law movers:
- r11v120repro/grid/T/t08_elem_sel_row_two_levels d/e enters STRICT_EQUAL in
  both views under CONNBOUNDCHAIN (a type-parameter `$bits(X)` port bound);
- r11u133repro/tix/t14 d enters STRICT_EQUAL (e moves in bytes) under
  BASEIDXELEM;
- r11u39repro/a2 d/e moves under BASEIDXELEM (stage 1 on every binary,
  chain toward 2).

These are three more conversions of the laws' general shapes.

## Residues (ranked; all wrong on pristine too)

1. **The range splice's nested levels** (V/VM/vm02_nontop d,
   `logic [D_HI:D_LO] r` in a non-top instance).
   - Face: golden keeps each nested sibling level of the splice at its own
     declaration span; only the top level is re-stamped (#91 / #92 line on
     every binary).  The law's share removes pristine's extra copies, whose
     records happened to match golden's nested copies, so the order-blind
     census reads lost 3 while chain away is 0.
   - Writer: TypeEmit `emitSyntaxExpr` § elabVarRangeMisevalSubst.
   - vm04 (top) is stage 1 on every binary.
2. **The m03 elaborated view** (r11u290 M/m03_tcm el, vc08, vc09, vc12, vc15,
   vc18 el): type at the RAM_SIZE_WORDS operand.  Law 4 is gated off in
   --elabuhdm, as the implementer reported.
3. **Law-1 shapes at stage 1 on every binary:** interface nets (vt05, vt20,
   vt21, vt22, whose typedef end is now golden's), a package net (vt03, vt04),
   generate-block nets (vt06, vt07), a function local (vt10), a port (vt11),
   an assigned net (vt15).  Also vt19, a struct member typed `p::t [2:0]`:
   endline → name, the member's own typespec.
4. **vc21 #370**, a port's ref_typespec whose golden full name is empty.
5. **The implementer's residues stand:** t09, the E-grid stage-1 positions,
   h13, h14/h16 and m01.

## Process

- Fence: every driver reads `$FENCED` fail-closed from
  tools/probe/r11u107repro/canaudit.sh (drivers/env.sh).
  - The census, mirrors, away, determinism (drivers/det.sh, rerow.sh) and
    byte controls (bytectl.sh) refuse or skip fenced names before opening
    any file.
  - The corpus `.sl` lookup in rerow.sh filters its path list by `$FENCED`.
  - Only Scr1SvTests, LogicTypespec, Earlgrey_0_1, the UVM rows and Rggen
    were re-run outside the gate sweeps.
- No process of another agent was listed or signalled.  The main tree was not
  written.
- THE VERIFIER'S SLIPS:
  - The first pristine sweep was launched twice into one workdir (see Gates)
    and discarded.
  - A `scripts/law_index.py --check` ran once from the main tree's root
    after a failed `rsync`; it is read-only and wrote nothing.
  - A `ls` of `$SURELOG_ROOT` with the variable unset listed the main tree's
    root directory.
- Drafts superseded: fix1 (two refinements), fixA (+ WRITERKIND), fixA2
  (+ SPLICESW), fixB (SPLICEOPND without its chain naming, vc13 still at
  fullname).  Every fix number above is from the final binary 2aeed421.
- Files: README.md, cases/{VT,VE,VH,VC,VM} (the first line of every source
  names its law), drivers/ (env.sh, case.sh, gridv.sh, grid.sh, away.py,
  awaychain.py, awayrows.py, awaycv.sh, awaycorp.sh, bvmirror.sh,
  tracecensus.sh, rerow.sh, det.sh, bytectl.sh, dscases.py,
  gridsum290.py, cc_x.sh, strictcmp_x.cpp), evidence/.
