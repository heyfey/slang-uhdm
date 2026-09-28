# r11u208 — second adversarial verification of passes 201 and 202

Base `032fbb89` (passes 202 at `0e776f9c` and 201 at `3668bf30` landed, then the r11u204 verification `93c4c999`
beneath them and the r11u205 decode, tools only, on top). Measurement only: no file under `src/`, `scripts/`,
`tests/`, `results/` or `third_party/` is edited by this directory; the one proven break's refinement is shipped as
[fix.patch](fix.patch) (not applied), gated by `R11V208_OPTGTANC_OFF` (`R11V208_OFF` drops it), header `src/R208.h`.
This pass was resumed after a session outage (11:51); every number below was re-read or re-measured after the resume
from the sweep logs, censuses and case runs named in `evidence/`.

## 0. Verdict

* **One break, refined:** § opCtxBindableTarget201v (v11u201's refinement of § opCtxRefArgBare201, `R11V201_OPTGT_OFF`)
  keeps the formal-typespec stamp on every continuous assignment in an interface body and on every implicit-net
  target, where golden is bare whenever an enclosing module instance declares the target's name (Surelog's
  `CompileHelper::bindVariable` recurses to the parent scope) and on every continuous assignment of an interface that
  is never instantiated. 14 of 24 fresh case-views (OB/b01-b05, b07, b08 both views) and OA/o06's `y` read the stamp
  away from golden under the landed refinement while the unrefined law is right there. The refinement
  **§ opCtxTargetAncestorBind208v** (`R11V208_OPTGTANC_OFF`) matches golden on every stamp cell of the 26 case-views
  but one (OB/b07 `--elabuhdm`, kept deliberately, section 4), fires on no corpus row, probe case or downstream lane
  and on no other tools/probe case (12583 case directories x 2 views), and moves 0 of 2560 + 4087 + 805 databases;
  every gate reads 0/0/0 and downstream 803/66/2/0.
* **One narrow away cell, not refined:** § classSpecExprArgUnlocated202 unlocates `m2.T`'s `param_assign` lhs where
  golden locates it when two `$unit` typedefs specialize one generic class (UT/u04, u07, u08): golden's `m2` there is a
  Surelog defect (a typedef alias of `m1`, `m1`'s line and `m1`'s single argument); the cell sits inside a stage-1
  structural divergence at the base and after, and no strict or downstream reader reaches it (section 5).
* **No other break** in 106 fresh cases x 2 views (212 case-views, 90 of them gridded law-by-law with every switch,
  both landings, all off and all off + R11V204_OFF): no crash of the law binary where a switched-off binary writes
  a database, no record moved away on the strict axis, no downstream verdict moved away from IDENTICAL.
* **Away-moved-record census (map 12's method, both landings, full corpora + probe):** LOST 0 on every mover
  (landing 201: 18 databases, 1246 records toward; landing 202: 52 databases, 1337 toward), positive control
  R11V202_OFF: 74 records away on 11 databases.
* **Composition:** every claimed conversion attributed (pass 202: ClassTypeParam d/t, int_types d/t and 14 probe
  cases; pass 201: 4 probe cases; SVSwitch d/t only with both); 0 byte-level cancellations over 6647 databases; the
  status-level BuildUVMPkg "cancel" (`line(11)` with both on and both off) is a count coincidence of two different
  databases.
* **Switch reach:** `R11U200_OFF` crosses the grounds (it drops pass 201's three r11u200 laws with pass 202's ten),
  `R11U201_OFF` leaves pass 201's three r11u200 laws on and drops only the refinement of one of them
  (`R11U201_NEWARRLAST_OFF` inside `r11u201On`), `R11U200_GENBITS_OFF` drops both halves of § genBlockBitsKeepsSelect200
  (one per ground; no switch drops one half alone except `R11U202_OFF` for the TypeEmit half), `R11V202_OFF` is
  redundant beside `R11U202_OFF`.
* **Determinism:** Earlgrey_0_1 one hash in 6 concurrent runs per mode; BuildUVMPkg one hash in 21 draws per mode (the
  v11u202 `this_type` draw not reproduced); SeqDriver and SimpleUVM one hash; MiniAmiq storage order only;
  Scoreboard default three hashes in three draws, order-blind identical, the svunit listing order reader-visible (92
  ordered-dump lines): confirmed.
* **Fence and process:** no fenced reading anywhere (section 12); every env.sh of the four directories fails closed;
  11 helper drivers do not check the fence themselves (none reads a corpus source or database directly); no driver
  writes relative to its current directory; both frozen predictions contain every mover measured here; SELFCHECK
  2559/2560 is byteverify's pass value.

## 1. Binaries and states

Frozen `chmod 555` in `/tmp/r11u208_bin` before any measurement ([evidence/sweeps/binaries_md5.txt](evidence/sweeps/binaries_md5.txt)):

| binary | md5 | what |
|---|---|---|
| `law.bin` | `d27bb984d49f` | `032fbb89` (= the main tree's build at the base) |
| `fix.bin` | `a8ebc7c86cab` | `032fbb89` + [fix.patch](fix.patch) (the worktree's build) |
| `fix1.bin` | `3351ca241cfc` | the first fix draft (superseded; not measured below) |
| `uhdm-strictcmp` | `fa6e4f42f252` | the base's strict comparator |

State wrappers ([evidence/sweeps/state_wrappers.txt](evidence/sweeps/state_wrappers.txt)); sweep tags `/tmp/r11u208_sw<tag>`:

| tag | state | switches |
|---|---|---|
| H | law | none |
| A | both landings off | `R11U200_OFF R11U202_OFF R11V202_OFF R11U201_OFF R11V201_OFF` |
| 1 | landing 201 off | `R11U201_OFF R11V201_OFF R11U200_NEWARRHP_OFF R11U200_UNITFOLD_OFF R11U200_FOLDDEPTH_OFF` |
| g | landing 201 off, both $bits halves | 1 + `R11U200_GENBITS_OFF` |
| b | landing 201's brief switches | `R11U201_OFF R11V201_OFF` |
| 2 | landing 202 off | `R11U202_OFF` |
| c | landing 202's brief switches | `R11U200_OFF R11U202_OFF R11V202_OFF` |
| V | v11u202's refinements off | `R11V202_OFF` |
| 4 | r11u204's refinements off | `R11V204_OFF` |
| W | all off + r11u204 off | A + `R11V204_OFF` |
| F | the fix | `fix.bin` (with `R11V208_TRACE`) |

**The switch map, read from src** (`r11u200Law` in UhdmExporter.cpp line 390 reads `R11U200_OFF` and `R11U202_OFF`;
the static `r11u200Law` copies in ExprEmit.cpp line 34 and ParamEmit.cpp line 25 read `R11U200_OFF` only;
`r11u202Law` line 442, `r11v202Law` line 454 reads `R11V202_OFF` or `R11U202_OFF`; `r11u201On` / `r11v201On` in
EmitHelpers.h lines 15181 / 15223):

* `R11U202_OFF` drops exactly landing 202 (its eight laws, the ten r11u200 ground-B laws and v11u202's five).
* `R11U200_OFF` drops the r11u200 laws of both grounds: as a landing-202 switch it over-reaches into landing 201
  (sweep c regresses pass 201's `s4_context` and `a1_newlhs` and puts SVSwitch back at `fullname(13)`).
* `R11U201_OFF` drops the six r11u201 laws and `R11U201_NEWARRLAST_OFF`'s refinement, but NOT
  § newArrayArgPathElemsStripped200 itself: under `R11U201_OFF` alone the new[] law runs unrefined, a state that
  never landed (sweep b: `s4_context`, `a1_newlhs`, SVSwitch stay converted by the unrefined law).
* `R11U200_GENBITS_OFF` is read by both halves of § genBlockBitsKeepsSelect200 (ExprEmit, landing 201; TypeEmit,
  landing 202).
* `R11V202_OFF` is redundant beside `R11U202_OFF`; `R11U200_CLASSCRASH_OFF`'s fallback runs only under
  `R11U196_MODGENERIC_OFF` / `R11U196_MODGENHANDLE_OFF` (K/k01 `--elabuhdm`: with those two off, the fallback on
  writes a database and the fallback off crashes rc 139: the guard works).

## 2. The gates of the fix (sweep F, `fix.bin`)

| gate | result |
|---|---|
| (1) build | `032fbb89` + fix.patch, `-j 2`; `R11V208_OFF=1` restores law.bin's bytes on all 38 OB/OA case-views ([evidence/fix/r11u208_obfix.txt](evidence/fix/r11u208_obfix.txt)) |
| (2) probe | EQUAL 3363 / STRICT_NOTEQUAL 724, `regressions=0 conversions=0 changes=0`, probe.csv byte-identical to sweep H |
| (3) surelog, uhdm2rtlil | `regressions=0 conversions=0 changes=0` both corpora (922 + 32; 1594 + 12); surelog.csv differs from H only in the LowMem detail text (workdir path); uhdm2rtlil.csv byte-identical |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, verdict columns identical to H |
| (5) uhdm-cmp | no row touched |
| (6) byteverify | `MOVERS: 0 / 2560`, SELFCHECK 2559/2560 (fence-free mirrors, `fenced_skipped=8`); probe 0 / 4087, downstream slang lane 0 / 805 ([evidence/fix/](evidence/fix/)) |
| firing census | `R11V208_TRACE` on sweep F: 0 trace files (positive control: OB/b01 writes one naming `iface z`, `iface u`); on 12583 tools/probe case dirs x 2 views: 15 case-views, all in this directory's OA/o06 and OB ([evidence/fix/r11u208_firecensus_named.txt](evidence/fix/r11u208_firecensus_named.txt)); 486 non-zero rcs, every one equal on law.bin (272 rc 3, 204 rc 4, 10 rc 139: pre-existing) |
| canaries | surelog ok=52 changed=0; uhdm2rtlil ok=16 changed=0; ctcan2 `EXPECT_UNKNOWN=1` PASS (ok=58), `EXPECT_UNKNOWN=6` PASS (ok=2) |

The fix's code path returns a different value only where its trace fires (the moved early return is pure
computation), so the firing census is its byte boundary.

## 3. The laws, fresh cases, three axes

106 fresh cases in `cases/` (each names its laws on its first line), goldens from the pinned Surelog with
check_probe's arguments, both views. `drivers/grid.py` runs each case under the law binary, the trace, each named
law's switch alone, each landing off, every pair of named laws off (group X), all off and all off + R11V204_OFF, and
scores pristine (switch on) against law: strict records when stage 1 is equal (TOWARD / MIXED / AWAY / UNMASK /
BYTES-ONLY), the order-blind dump distance to golden and the lines golden and pristine share that the law lost
(`drivers/dumpaway2.py`, `drivers/recaway2.py`) when stage 1 differs, which it does on most small shapes at the base
(interface, class and program structure). Downstream verdicts per case through the harness's own `one()`
(`drivers/dscase.py`). Per-law tally over both views ([evidence/grid/r11u208_lawtable.txt](evidence/grid/r11u208_lawtable.txt)):

| law (switch) | cases | fired case-views | verdicts (law vs its switch off) | away | verdict |
|---|---|---|---|---|---|
| § tfSigningSpanFollowsCompilePath200 (`R11U200_SIGNSPAN_OFF`) | SS/s01-s07: signed/unsigned on bit, logic, reg, integer, int, byte, shortint, longint, time, typedefs, macro args, ANSI / non-ANSI formals, returns, generate variables, class properties, struct members | 12 | TOWARD 4, STAGE1-CLOSER 8 | 0 | holds |
| § defGenInitRhsKeepsParent200 (`R11U200_GENINIT_OFF`) | GI/g01-g04, X/x07 | 10 | TOWARD 4, STAGE1-CLOSER 6 | 0 | holds |
| § ifaceArrPortElemViewNamedByArray200 (`R11U200_IFARRNAME_OFF`) | IA/i01-i08, X/x05: depths 1-3, modport-qualified and plain, named and positional, struct member, program port | 10 | TOWARD 6, UNMASK 2 (i07), STAGE1-SAME 2 (i06) | 0 | holds; i06 residue (section 11) |
| § implicitTsEndCrossesLineBreak200 (`R11U200_IMPLEND_OFF`) | IE/e01-e04 | 8 | TOWARD 8 (all four convert, both views) | 0 | holds |
| § defPortPackedTsKeepsWholeSpan200 (`R11U200_PORTPACKED_OFF`) | PP/p01-p09, X/x04, x08: no keyword, 1-3 dims, wire, tri, var, bit, reg, signed, unsigned, interface and program ports, redeclared ports | 8 | TOWARD 6, MIXED 2 (p09) | 0 fields | holds; p09 residue |
| § unitBoundFoldAtLeftOperand200 (`R11U200_UNITINIT_OFF` / `UNITFOLD_OFF` / `FOLDDEPTH_OFF`) | UF/f01-f02, X/x06 | 6 | STAGE1-CLOSER 14, STAGE1-SAME 4 | 0 | holds; parenthesis residue |
| § classTdRetSharesTypedefTs200 (`R11U200_CLASSTDRET_OFF`) | TR/t01-t05, X/x03, x09: K::T, pkg::K::T, this_type, typedef of a specialization, extern prototype with an out-of-block body, a split return with a comment, CRLF | 14 | STAGE1-CLOSER 14 | 0 | holds |
| § posOpConnKeepsRefModule200 (`R11U200_POSREFMOD_OFF`) | PQ/q01-q02 | 4 | STAGE1-CLOSER 4 | 0 | holds |
| § genBlockBitsKeepsSelect200 (`R11U200_GENBITS_OFF`, both halves) | GB/b01-b02, X/x07 | 6 | STAGE1-CLOSER 6; downstream GB/b01, b02, X/x07 DIVERGENT (all off) -> IDENTICAL | 0 | holds |
| § modGenericClassListedAtDefault200 (`R11U200_CLASSCRASH_OFF`) | K/k01-k02 | 0 by default; fallback state k01: STAGE1-CLOSER, k01 `--elabuhdm` fallback off rc 139 | – | – | guard works |
| § unitClassTdSpecAtName202 (`R11U202_UNITCLSTD_OFF`) | UT/u01-u04 | 4 | MIXED 2 (u01), STAGE1-CLOSER 2 | 0 fields | holds; u01 = v11u202's V1 |
| § unitClassTdEndAtInit202 (`R11U202_CLSTDINITEND_OFF`) | UT/u01-u04 | 4 | TOWARD 2, STAGE1-CLOSER 2 | 0 | holds |
| § classSpecExprArgUnlocated202 (`R11U202_SPECARGS_OFF`) | UT/u01, u03-u08, X/x02 | 8 (+ u05-u08 by case.sh) | TOWARD 2, STAGE1-CLOSER 6; u06 converts both views | **2 cells (u04; u07, u08)** | section 5 |
| § classValueParamIntSigned202 (`R11U202_CLSPARAMSIGN_OFF`) | CV/v01-v02, CB, K, UT/u03 | 6 | STAGE1-CLOSER 6 | 0 | holds |
| § modPkgGenericSpecNamedBare202 (`R11U202_MODPKGSPEC_OFF`) | NP/n01-n03: `p::C #()`, nested packages, a generate block, a program | 6 | STAGE1-CLOSER 6 | 0 | holds |
| § modSpecValueArgSpanAtName202 (`R11U202_VALSPECSPAN_OFF`) | VS/a01-a02 | 4 | TOWARD 2, STAGE1-CLOSER 2 | 0 | holds |
| § genVarInitOuterRefUnbound202 (`R11U202_GENINITBIND_OFF`) | GI/g01-g04, X/x07 | 3 | STAGE1-CLOSER 2, BYTES-ONLY 1 | 0 | holds |
| § defGenInitBitSelAtIndex202 (`R11U202_GENINITBS_OFF`) | GI/g01, g02, g04: 2-D net, package constant, enclosing genvar, a call, generate-if inside generate-for | 6 | TOWARD 4, STAGE1-CLOSER 2 | 0 | holds |
| § portPackedBareImplicitTruncates202v (`R11V202_PORTIMPL_OFF`) | PP, X/x04, x08 | 4 | TOWARD 4 | 0 | holds |
| § classTdRetVarKeepsWrittenLoc202v (`R11V202_TDRETVAR_OFF`) | TR | 4 | TOWARD 2, STAGE1-CLOSER 2 | 0 | holds |
| § implicitTsEndAfterLineComment202v (`R11V202_IMPLCMT_OFF`) | IE | 6 | TOWARD 6 | 0 | holds |
| § implicitTsEndSkipsCarriageReturn202v (`R11V202_IMPLCR_OFF`) | IE/e02, e04 (CRLF) | 2 | TOWARD 2 | 0 | holds |
| § modSpecValueArgDefViewMultiArg202v (`R11V202_VALSPECDEF_OFF`) | VS/a01-a02 (three ordered args, mixed named) | 4 | STAGE1-CLOSER 2, BYTES-ONLY 2 | 0 | holds |
| § newArrayArgPathElemsStripped200 (`R11U200_NEWARRHP_OFF`) | NA/a01-a04, X/x05: this. / super. paths, a call as the size, depth 2-3, a queue property, an interface-array element size | 6 | TOWARD 4, STAGE1-CLOSER 2 | 0 | holds |
| § newArrayPathStripTrailOnly201v (`R11U201_NEWARRLAST_OFF`) | NA | 4 | TOWARD 1, STAGE1-CLOSER 3 | 0 | holds |
| § clsScopedBoundWholeSpan201 (`R11U201_CLSBOUND_OFF`) | CB/c01-c03, X/x02: localparam, parameter, enum constant, K#(4)::V, K::L::V, both bounds, indexed part select | 6 | TOWARD 2, STAGE1-CLOSER 4 | 0 | holds |
| § sysCtxRefArgBare201 (`R11U201_SYSARG_OFF`) | SA/s01-s05, X/x01, x10: $signed, $unsigned, $clog2, $countones, $bits, $size, $high, user calls depth 1-3, interface, program, generate, implicit-net target | 12 | STAGE1-CLOSER 12 (s03's 5 order-blind "lost" lines are a multiset artifact: the placement-aware stamp table reads law = golden, section 6) | 0 | holds |
| § opCtxRefArgBare201 (`R11U201_OPARG_OFF`) | OA/o01-o07, OB, X/x04, x08: targets in the body, an ancestor, a child, a bind, an interface, a program | 14 | TOWARD 1, STAGE1-CLOSER 13 | 0 | holds |
| § nonReduceOpArgBare201 (`R11U201_NONRED_OFF`) | OA/o03 | 2 | STAGE1-CLOSER 2 | 0 | holds |
| § methodArgNestedRefChain201 (`R11U201_MARGNEST_OFF`) | MN/m01-m02, X/x03, x09: nested 2-3 deep, a call in the operation, a bit select inside | 6 | TOWARD 4, STAGE1-CLOSER 2 | 0 | holds |
| § callArgInSelIdxChainName201 (`R11U201_SELIDXCALL_OFF`) | SI/n01-n03: compound assignments, inc/dec operands, streaming lvalues | 4 | TOWARD 2, STAGE1-CLOSER 2 | 0 | holds |
| § opCtxBindableTarget201v (`R11V201_OPTGT_OFF`) | OA/o06, OB/b01-b08, c01-c04 | 2 in the grid (o06); OB by case.sh | the grid's STAGE1-CLOSER on o06 hides one cell away; OB: section 4 | **16 case-views** (OB 14, o06 2) | **BREAK, refined** |
| § clsScopedBoundPlainClass201v (`R11V201_CLSPARAM_OFF`) | CB/c01-c02, X/x02 | 4 | STAGE1-CLOSER 4 | 0 | holds |
| § newArrayKeepFrozenBare201v (`R11V201_NEWARRBARE_OFF`) | NA/a01, a03, a04 | 2 | STAGE1-CLOSER 2 | 0 | holds |

No crash: every grid state wrote a database except K/k01 `--elabuhdm` with the class-listing fallback forced off
(an off state of a crash guard, not a law). Downstream (both states, [evidence/downstream/](evidence/downstream/)):
every case IDENTICAL on the law binary except IA/i02 STATUS_DIFF (Surelog lane READ_FAIL), NP/n03 EQUIVALENT (no
common assign), SA/s02 EQUIVALENT, X/x01 DIVERGENT, OB/b05, OB/c01, OA/o06 EQUIVALENT, all identical with both
landings off (base residues); GB/b01, GB/b02, X/x07 DIVERGENT with both landings off -> IDENTICAL with them on.

## 4. BREAK: § opCtxBindableTarget201v over-declines (refined by § opCtxTargetAncestorBind208v)

**Decode (Surelog source only).** `UhdmWriter::writeCont_assign` (third_party/Surelog/src/DesignCompile/UhdmWriter.cpp
line 2123) clones a continuous assignment whose target `bindVariable` finds and whose right side is an operation;
the clone's arguments are reduced and stamped, the listing's own objects stay bare.
`CompileHelper::bindVariable` (CompileStmt.cpp line 3095) searches a `module_inst` scope's `Variables()` and
`Nets()` and otherwise, and after any miss, recurses into `scope->VpiParent()` (line 3156). An interface body's scope
is an `interface_inst` (no case: straight to the parent), so an interface's target name binds when any enclosing
module instance declares a net or variable of that name; an implicit net of a child binds through the parent the
same way. § opCtxBindableTarget201v declined (kept the stamp) on every interface body and every implicit-net target.

**Grid** ([evidence/fix/r11u208_obstamp.txt](evidence/fix/r11u208_obstamp.txt), `drivers/stampcheck.py`: per user call
`f(...)`, whether its reference argument carries a `vpiTypespec`, keyed by line and listing indentation; `@6` is the
definition listing; S stamped, b bare):

| case | shape | golden | law (landed) | unrefined (`R11V201_OPTGT_OFF`) | fix |
|---|---|---|---|---|---|
| OB/b01 | interface vars `z`, net `u`; top declares `u` and port `z` | b b | S S | b b | b b |
| OB/b02 | interface never instantiated | b b | S S | b b | b b |
| OB/b03 | `z` declared two levels up (top above mid) | b | S | b | b |
| OB/b04 | child's implicit net `imp`, parent declares `imp` | b | S | b | b |
| OB/b05 | interface output port `y`, top port `y` | b | S | b | b |
| OB/b06 | first instance under a module without `z`, second under one with it | S | S | b | S |
| OB/b07 | interface in a generate block, top declares `z` | b | S | b | b (default view) / S (`--elabuhdm`) |
| OB/b08 | implicit net, child in a generate block | b | S | b | b |
| OB/c01 | port connected to a differently named net | S | S | b | S |
| OB/c02 | interface net and variable, top declares neither | S S | S S | b b | S S |
| OB/c03 | uninstantiated module, implicit net | S | S | b | S |
| OB/c04 | the name declared only inside a sibling generate block | S | S | b | S |
| OA/o06 | `y` bound by the instantiating module; `7:14`, `12:16` not | b S S | S S S | b b b | b S S |

Both views read the same except where named. The fix reads the representative instance the definition listing is
emitted from (b06: Surelog's listing hangs under its first instance's chain). OB/b07 `--elabuhdm`: our elaborated
generate-scope interface re-lists the very objects of the definition listing, where golden writes a separate,
reduced, stamped copy (`@12=S`), so the fix keeps the stamp there (one cell away either way; residue R4). The
remaining OA/o01 `13:14` second-listing cell is S in law, unrefined and fix alike (not this law's).

**Measurement.** Strict stage 1 differs on most OB shapes at the base (interface ports are `logic_var` where golden
writes `logic_net`); OB/b04 `--elabuhdm` and OB/b08 `--elabuhdm` convert NOT_EQUAL -> STRICT_EQUAL (158 and 163
objects); OB/b05 and OA/o06 `--elabuhdm` read 60 uhdm-cmp lines instead of 17 because the stamp was the first
difference and the next one (the port kind, present unchanged in law's database: 5 `logic_var` against golden's 6
`logic_net`) is now reached: an unmasking. Downstream: every OB case the same verdict under law and fix (stamps do
not reach the plugin). Section 2 has the gates.

## 5. The narrow away cell of § classSpecExprArgUnlocated202 (not refined)

UT/u04, u07, u08: `typedef cfg#(obj, obj2) m2; typedef cfg#(obj) m1;` in either order. Golden writes `m2` as a typedef
alias of `m1` (`vpiTypedefAlias` -> `m1`, located at `m1`'s line, one parameter `T` -> `obj`) whose `param_assign`
lhs `m2.T` is a located clone of the class's `T` (6:17-6:18, typespec `int` 6:19-6:22). Pristine writes `m2` with
two located parameters, the law with two unlocated ones; the two located lhs records golden and pristine share are
unlocated by the law. The object sits inside a structural divergence at the base and after (golden's `m2` has one
parameter and aliases another typedef; stage 1 differs on both binaries; a partial specialization alone, UT/u05, is
already stage-1 different at the base: golden lists only the given parameters), so no strict walk and no downstream
reader (class typespecs do not reach the plugin; UT/u04-u08 IDENTICAL downstream) reaches the cell. A refinement
would have to reproduce the alias, a Surelog defect the base does not model; with one typedef (UT/u06) the law
converts both views. Reported, not refined.

## 6. The other mixed readings (none away on a field)

* PP/p09 (MIXED at record level): the non-ANSI `input [N-1:0][3:0] a;` redeclared by `wire`: golden 3:9-3:16 (the
  first dimension), pristine 3:9-4:15 (running into the redeclaration), law 3:9-3:21: the law fixes the end line and
  leaves a wrong end column; `input signed [N-1:0][3:0] b` goes 5:23 -> 5:15 = golden. Residue R5.
* UT/u01 (MIXED at record level): the typedef's end golden 9:18 (an interface variable's initializer), pristine 7:26,
  law 7:12: end line and column wrong in both = v11u202's V1 (landed on the main tree by pass 206, after this base).
* IA/i06 (STAGE1-SAME): a program's interface-array port; golden writes one element named `o.o`, pristine
  `work@top.TC.o[k]`, law `o.o[k]`: neither agrees.
* UF/f02, X/x06: the folded constant the law relocates has no golden object (golden keeps the operation) in f02; in
  x06 golden spans the parenthesised left operand `(M << 2)` 3:26-3:34, law 3:27-3:33 (pristine 3:27-3:28): closer,
  both wrong. Residue R6.
* X/x09 `newbad=1`, SA/s03 `lost=5`: the dump header line, and a multiset artifact (golden has 16 `vpiTypespec`
  lines elsewhere that ours lacks); the placement-aware stamp table of s03 reads law = golden on every call
  (`5:25`, `9:26`, `14:27` bare), pristine stamped.

## 7. Composition ([evidence/compose/](evidence/compose/))

| corpus | conversions both-off -> law | attributed |
|---|---|---|
| probe | 18 | OWN201 4 (`r10svs2repro/s4_context`, `r10svs3repro/a1_newlhs`, `r10uvm60repro/v2_class`, `v11u112repro/grid/brk/t/b2c_iface_fn`), OWN202 14 (the 7 r10rgg6 `p2` cells, `r10earl109repro/g6_carrier109`, `r10sd1repro/b9_inline`, `r10svs11repro/v3_arr`, `r10uvm55repro/a1`, `r10uvm70repro/a1_ret`, `r10uvm97repro/g97_a1_selftd`, `g97_a4_plainclass`, `r10v97repro/v97_c1_mixedgroup`) |
| surelog | 4 | SVSwitch d/t JOINT (201 off: `fullname(2)`; 202 off: `endline(11)`), ClassTypeParam d/t OWN202 |
| uhdm2rtlil | 2 | int_types d/t OWN202 |

Changes (not conversions) both-off -> law: probe OWN201 1 (`g193_c_argface` 102 -> 94), OWN202 13 (twelve r10rgg6
cells `endcol` -> `line`, `v6_ndecl78` 3 -> 2); surelog JOINT 9 (the UVM rows, Scr1SvTests), OWN202 5 (Earlgrey d/t
82 -> 76, Rggen d, UnitElabBlock d/t). Byte level over 6647 databases (`drivers/bytecancel.py`): L != A on 57 (BOTH
13, OWN201 5, OWN202 39), **CANCEL 0**. The four status-level "cancels" (BuildUVMPkg d/t reads `line(11)` both on and
both off, `line(5)` with 202 off, `line(24)` with 201 off) are two different databases (BOTH) whose first-field counts
coincide. R11V204_OFF: probe 0 / 4087 movers; corpus 9 / 2560 (the UVM row-modes, BuildUVMPkg deterministically),
order-blind 0 lines and ordered uhdm-dump identical with ids: bytes the dump does not print.

Cross-ground pairs (group X, every pair of named laws switched off, both views): x07 (the two $bits halves), x06 (the
reduced bound with the $unit initializer half), x05 (new[] over an interface-array element: PAIR TOWARD 12 records,
EQUAL 209 objects with both), x01 / x10 (stamped and kept: each law alone and in pairs closer, x10 `--elabuhdm`
§ evalFuncOmittedDefaultKeepsCall196 alone `newbad=1` a header line), x02 (the specialization bound), x03 / x09 (a
class-typedef return with a nested argument), x04 / x08 (a bare packed port target): no pair reads a record away, no
pair's joint effect differs in sign from its members'.

## 8. The CHANGES: unmasking proofs and the away census

`drivers/unmask2.py` (record lists with walk indices, golden vs each database; SUBSET = every record of the law side
is one the off side had; UNMASK = every new record sits at or past the off side's walk divergence index):

| comparison | probe | surelog | uhdm2rtlil |
|---|---|---|---|
| landing 201 (sweep 1 -> H) | CONVERSION 4, SUBSET 1 | CONVERSION 2, SUBSET 11 | – |
| landing 201 over both off (A -> 2) | CONVERSION 4, SUBSET 1 | SUBSET 13 | – |
| landing 202 (2 -> H) | CONVERSION 14, SUBSET 13 | CONVERSION 4, SUBSET 7, UNMASK 9 | CONVERSION 2 |
| landing 202 over both off (A -> 1) | CONVERSION 14, SUBSET 13 | CONVERSION 2, SUBSET 9, UNMASK 9 | CONVERSION 2 |

Every grown count is an unmasking: BuildUVMPkg d/t, MiniAmiq d/t, Scoreboard d, SeqDriver d/t, SimpleUVM d/t (the
walk divergence moves from about #10100-#11992 to #20788-#22506 with every new record past it; first records
identical except SeqDriver, whose off-side first record `#5387 space.substr::i` is one pass 201 removes). Every
shrunk count is a strict subset. NEW 0.

Away census (map 12's method, `drivers/awayrows.py`, records keyed without depth; LOST = golden and the off side
share, the law side lacks): landing 201: 18 databases, away 0 on each (toward 1246 records); landing 202: 52
databases, away 0 on each (toward 1337; the 202 byte movers `r10svs11repro/v3_arr`, `r10v119repro/v119_h`, `v119_j`
toward 0 away 0: order or depth only); the same over both-off bases (A -> 2, A -> 1): identical. Positive control
(H -> V, R11V202_OFF): 11 databases, 74 records away (Earlgrey d/t 4 each, BuildUVMPkg d/t 5 each, MiniAmiq,
SeqDriver, SimpleUVM d/t and Scoreboard d 8 each).

## 9. Downstream

| row | law | both landings off | golden lane |
|---|---|---|---|
| ClassTypeParam (surelog row, `drivers/dsrow.py`) | IDENTICAL | IDENTICAL | byte-identical netlists |
| SVSwitch (surelog row) | IDENTICAL | IDENTICAL | byte-identical |
| int_types (downstream lane) | IDENTICAL | IDENTICAL | byte-identical |

The downstream csv verdict columns are identical between sweeps A and H (and F). Pass 201's z05-z08 (and v11u201's
g03, g05): DIVERGENT with both landings off -> IDENTICAL: confirmed. v11u202's PP/p05 (`input var` / `input bit`
packed ports): DIVERGENT on law and on both-off alike: confirmed at the base.

## 10. UVM distances (both measures)

`drivers/uvmdist.sh`: dist = records ours holds that golden lacks (r11u202's measure), sym = dist + records golden
holds that ours lacks (r11u201's measure); default mode (testflags equal).

| row | both off (A) | 201 off (1) | 202 off (2) | law (H) |
|---|---|---|---|---|
| MiniAmiq | 6886 / 15559 | 6781 / 15352 | 6739 / 15265 | 6634 / 15058 |
| SeqDriver | 5472 / 11805 | 5372 / 11608 | 5294 / 11449 | 5194 / 11252 |
| SimpleUVM | 2312 / 4538 | 2220 / 4352 | 2166 / 4246 | 2074 / 4060 |
| Scoreboard | 1736 / 3451 | 1645 / 3267 | 1617 / 3213 | 1526 / 3029 |
| BuildUVMPkg | 954 / 1907 | 847 / 1693 | 883 / 1765 | 776 / 1551 |

Pass 201's figures (15559 -> 15265, 11805 -> 11449, 4538 -> 4246, 3451 -> 3213, 1907 -> 1765) reproduce exactly (A
-> 2). Pass 202's (6886 -> 6789, 5472 -> 5380, 2312 -> 2228, 1736 -> 1653, 954 -> 852) read 8, 8, 8, 8, 5 lower here
(A -> 1): exactly the records v11u202's refinements add toward golden (the R11V202_OFF positive control moves 8 per
UVM row and 5 on BuildUVMPkg): pass 202 measured before its verifier's refinements. Both measures fall on every row
under each landing alone and additively under both. First records at the base
([evidence/residues/r11u208_heads_H.txt](evidence/residues/r11u208_heads_H.txt)): MiniAmiq #899, SeqDriver #10090,
SimpleUVM #458, Scoreboard #466, BuildUVMPkg #3245.

## 11. Determinism ([evidence/determinism/](evidence/determinism/))

law.bin, the sweep's own command lines and cwd, concurrent draws:

| row | draws per mode | distinct hashes | reading |
|---|---|---|---|
| Earlgrey_0_1 | 6 (+ the sweep's) | 1 / 1 | deterministic |
| BuildUVMPkg | 21 (3 + 3 x 6) | 1 / 1 (default and testflags the same bytes) | the v11u202 `this_type` draw (1 of 18) not reproduced in 21 |
| SeqDriver, SimpleUVM | 3 | 1 / 1 | deterministic |
| MiniAmiq | 3 | 2 / 2 | order-blind 0 lines, ordered dump (ids stripped) 0 lines: storage order only |
| Scoreboard default | 3 | 3 | order-blind 0 lines; the ordered dump differs by 92 lines (`svunit_pkg::svunit_base`'s task/function listing order): the reader-visible coin, confirmed |

## 12. Residues

Re-measured at the base ([evidence/residues/](evidence/residues/)):

| residue | status at `032fbb89` |
|---|---|
| 202 #1 the UVM rows' first records | MiniAmiq #899 (`uvm_severity` file) stands; SeqDriver's `space.substr::i` gone (pass 201), head now #10090 (`<in>uvm_pkg::uvm_event_pool` ref_typespec full name); SimpleUVM #458 / Scoreboard #466 `UVM_MACRO_*` stand; BuildUVMPkg #3245 (`uvm_action`) stands |
| 202 #2 UnitElabBlock d/t `file(2)` / `file(1)` | stands (#105 `logic_net hold` carries `top.v`) |
| 202 #3 SVSwitch d/t | resolved (converted by the composition) |
| v202 V1 interface / program typedef end | stands (UT/x01, x02 `endline`; this pass's UT/u01); landed on the main tree by pass 206 |
| v202 V2 the `this_type` draw | not reproduced in 21 + 21 draws |
| v202 V3 the elaborated view with named arguments (VA/a05) | does not reproduce: STRICT_EQUAL 36 objects in both views |
| 201 #1 the joint rows' B halves | SVSwitch converted; Scr1SvTests at `type(1)` (#48892, the Surelog binding defect, report only); z05 / z08 STRICT_EQUAL both views |
| 201 #2 the UVM first records | as 202 #1; BuildUVMPkg #5639 next |
| 201 #3 Earlgrey #90097 | stands |
| v201 #1 ground-B halves | resolved as 201 #1 |
| v201 #2 § opCtxRefArgBare201 in `--elabuhdm` (q01, q09, q10) | stands (q01 `type(1)`, q09 / q10 stage 1) |
| v201 #3 the middle-position / streaming select-index name (n01, n06) | stands (stage 1) |

New residues of this pass: R1 the § classSpecExprArgUnlocated202 alias cell (section 5); R2 a partial specialization
lists the defaulted parameters golden omits (UT/u05, base); R3 interface output ports written `logic_var` where golden
writes `logic_net` (OB/b05, OA/o06: downstream EQUIVALENT at the base); R4 OB/b07 `--elabuhdm` shared definition /
elaborated interface objects in a generate scope; R5 a non-ANSI packed port redeclared by a net keeps golden's
first-dimension end (PP/p09, § portPackedBareImplicitTruncates202v reads ANSI headers only); R6 a parenthesised left
operand of a reduced `$unit` bound (X/x06: golden includes the parentheses); R7 a program's interface-array port
elements (IA/i06: golden one element `o.o`).

## 13. Fence and process ([evidence/fence/](evidence/fence/))

* **This pass.** Every driver sources `drivers/env.sh`, which reads the four names from the `FENCED=` line of
  tools/probe/r11u107repro/canaudit.sh and refuses without four (runtime check: rc 1 against a two-name canaudit copy);
  corpus databases were byte-compared only through fence-free hard-link mirrors (`fenced_skipped=8`); the probe and
  downstream lane comparisons drop fenced paths by word boundary before opening anything (`drivers/lanebytes.sh`:
  `fenced_skipped=0`, no fenced name in either workdir); no fenced source or database was run, read, dumped or
  decoded; no gdb. The gate sweeps ran the whole corpora as the gate does; their csv verdicts of fenced rows are the
  only fenced facts and none moved. A word scan of this directory finds no fenced name (positive control: a planted
  name found).
* **The two laws nearest the fenced shapes, re-derived from fresh cases and Surelog's source only:** § opCtxRefArgBare201
  with its refinement (sections 3-4: OA / OB grids, `writeCont_assign` and `bindVariable` decoded from source), and
  § defPortPackedTsKeepsWholeSpan200 with § portPackedBareImplicitTruncates202v (PP/p01-p09: every port form of the
  brief, golden from the pinned Surelog; TOWARD on every fired case-view, the p09 residue named).
* **The four directories.** Every env.sh fails closed (checkout rc 0, four names; two-name canaudit rc 1). Static audit
  of their 61 drivers (`drivers/fenceaudit.py`, [evidence/fence/r11u208_fenceaudit.txt](evidence/fence/r11u208_fenceaudit.txt)):
  drivers that do not themselves refuse without `$FENCED`: r11u201repro `censum.py`, `ctlsum.py`, `obdist.sh`;
  v11u201repro `awayall.sh` (relies on its callee `away.sh` sourcing env.sh), `censum.py`; r11u202repro `censum.py`,
  `spantab.py`; v11u202repro `away.py`, `ob.py`, `censum.py`. None reads a corpus source or database directly (trace
  files, csvs, case dumps, or databases handed in by a fenced caller: awaycorp.sh, obcorp.sh refuse fenced paths);
  r11u202repro and v11u202repro `det.sh` / `detob.sh` have no filter of their own (their row list names no fenced
  test; `rowrun.sh` refuses the four names). No file in the four directories names a fenced test (word scan 0,
  positive control 1). The "byte-free shell loop that spelled the names" v11u202 admitted is not in its README, its
  drivers or the landing commit message; nothing in the committed tree spells a name.
* **No driver writes relative to its current directory** (static scan of redirections, `-o`, `open(..., 'w')`, `cp`,
  `mv`, `mkdir` targets; the hits are loop words read by hand); the drivers that `cd` into a case write with absolute
  output paths.
* **Predictions.** r11u202repro's `predicted_movers.txt` (md5 `d04ab854` = the md5 in its `frozen_at.txt`, stamped
  06:24:22 -04:00 "before the law sweep /tmp/r11u202_sL started"): 123 corpus row-modes + 156 probe cases; all 52
  databases landing 202 moves at this base are inside it (22 corpus row-modes, 30 probe). r11u201repro's (md5
  `ac88b3ac` = frozen_at, 10:29:31Z): 19 corpus row-modes, 6 probe, 1 downstream; all 18 databases landing 201 moves
  here are inside it (13 + 5). The pairs' sweep workdirs are pruned, so the time order rests on those stamps; v11u201's
  prediction carries no frozen_at file. **SELFCHECK 2559 / 2560** is byteverify's negative control passing: every file
  compared with one fixed file must differ, and the fixed file equals itself (na - 1).
* **Packaged cases.** Every case of the four directories (48 + 74 + 84 + 51) carries a `§` first line (or a LAW
  file), and every `§` name cited exists in src.

## 14. Files

* `fix.patch` — the refinement (src/ExprEmit.cpp `r208AncestorBinds`, `caTargetBindable201v`; src/R208.h), not applied.
* `cases/` — 106 cases (`dut.sv`, first line = laws; K/* `extra` = the fallback states).
* `drivers/` — `env.sh` (pins, fence), `grid.py` / `gridall.sh` (the law grid), `case.sh` (one case), `lawtable.py`,
  `stampcheck.py`, `dscase.py` / `dsrow.py` (downstream), `sweep.sh` / `queue.sh` / `mkstate.sh` (gate sweeps and state
  wrappers), `bvmirror.sh`, `lanebytes.sh` (byte comparisons), `bytecancel.py` / `compose.py` (composition),
  `unmask2.py` (unmasking), `awayrows.py` / `recaway2.py` / `dumpaway2.py` (away censuses), `uvmdist.sh`, `det.sh` /
  `ob.sh` / `obpair.sh` (determinism), `firecensus.sh` / `fixbound.sh` / `fixjudge2.py` (the fix's boundary),
  `fencecheck.sh` / `fenceaudit.py` (the fence), `laws.py` (the law -> switch map).
* `evidence/` — `sweeps/` (every gate sweep's summary, binaries, wrappers), `grid/`, `fix/`, `compose/`, `unmask/`,
  `census/`, `downstream/`, `determinism/`, `residues/`, `fence/`.

The law index (tests/LAWS.md) is stale against this directory's new cases (the sweeps print `law index STALE`,
SWEEP_RC 1); the integrator regenerates it with scripts/law_index.py.
