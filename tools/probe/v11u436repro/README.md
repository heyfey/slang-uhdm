# v11u436: adversarial verification of r11u436 (the module/type ground, pair B)

Base `c0096a9a` (branch matrix-1.87). Implementer's patch `/tmp/r11u436.patch` applied clean on a
fresh worktree `/tmp/wt_v11u436`. Verdict: **the implementer's headline numbers reproduce
bit-for-bit; THREE BREAKS found on fresh legal SV where pristine was right on a field and the law
wrong; all three fixed behind their own switches** (`/tmp/r11u436.verified.patch`).

Binaries (frozen, `cmds.txt` audited):

| binary | md5 | role |
|---|---|---|
| `/tmp/v11u436_bin/pristine` | `3da951e1eb1969ab5fc9812f41f9725a` | main tree `build/slang-uhdm` at the base (no pristine build, no pristine sweep: the pristine reading is the master's control `/tmp/intr11u434`) |
| `/tmp/v11u436_bin/law` | `5763a78b4576322e97b9fa6267effdb3` | the implementer's patch rebuilt once, equal to its `law19` |
| `/tmp/v11u436_bin/ver3` | `b841e9bc96e7d6749350b38efc4849eb` | the verified binary swept in full |
| `/tmp/v11u436_bin/ver4` | `8a6ba11216464c685ea5910e944b7145` | the final verified binary: ver3 with the trace of § cgArrDefNetDimEnd436v moved behind its array test (no byte change, below) |

## The rows (fresh csv rows; results/ untouched)

| row | base | law (= verified) |
|---|---|---|
| `generated/hdlconv_std2017/hdlconvertor_std2017_p203.sv` | DIFFERENT | `...p203.sv,EQUAL,,equal` |
| `generated/hdlconv_std2017/hdlconvertor_std2017_p334.sv` | DIFFERENT | `...p334.sv,EQUAL,,equal` |
| `generated/hdlconv_std2017/hdlconvertor_std2017_p719.sv` | DIFFERENT | `...p719.sv,EQUAL,,equal` |
| `generated/uvm-examples/apb_protocol_monitor.sv` | DIFFERENT | `generated/uvm-examples/apb_protocol_monitor.sv,STRICT_NOTEQUAL,differ:col(1),differ:col(1)` |

sv-tests on both the law and the verified binary: EQUAL 1906, STRICT_NOTEQUAL 1, DIFFERENT 33,
BOTH_REJECT 303, SURELOG_ONLY 75, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0,
conversions 4, changes 0. The law csv is identical to the implementer's law19 csv on all 2346 rows
and differs from the control in exactly the four rows above (evidence/svtests_law_vs_control.diff);
the verified csv is identical to the law csv (evidence/svtests_verified_vs_law.diff, empty).

## Gates (evidence/sweep_summary.txt)

One full five-stage sweep each on `law` (`/tmp/v11u436sw1`) and `ver3` (`/tmp/v11u436sw2`), the four
corpus stages from the worktree, the sv-tests stage through the main tree's
`scripts/check_svtests.py` with the worktree's baseline (a worktree's UVM tree is empty;
drivers/fullsweep.sh), each launched after three quiet readings, `R11U436_TRACE` on.

- probe: EQUAL 4019 + STRICT_NOTEQUAL 68 of 4087, regressions 0 / conversions 0 / changes 0 on both;
  the csv identical to the control; the 4087 databases identical by path-normalized dump law vs
  control, verified vs law and ver4 vs ver3 (positive control: two different cases' dumps read DIFF).
- surelog: default CMP_EQUAL 480, testflags 474, 0/0/0 on both; the csv differs from the control
  only in the two LowMem log-path texts (and is otherwise identical to the implementer's).
- uhdm2rtlil: 803 / 1 / 67 in both modes, 0/0/0, csv identical to the control on both.
- downstream: IDENTICAL 803, SLANG_REJECT 66, EQUIVALENT 2, DIVERGENT 0 of 871, csv identical to
  the control on both.
- the corpus stages exit 1 on the stale law index alone (tests/LAWS.md regenerated into the patch).
- byteverify (SELFCHECK=1, evidence/byteverify.txt): law vs control, verified vs law and verified vs
  control each 0 of 962, 0 of 1608 and 0 of 805, the self-checks flagging 961, 1607 and 804.
- canaries ok=52 and ok=16 changed 0; ctcan2 PASS with `EXPECT_UNKNOWN=1` and `=6`, on both sweeps
  (evidence/canaries.txt).
- binary audit (fence-filtered, evidence/binary_audit.txt): surelog 1523 of 1573 command records
  name the binary under test, the other 50 a Surelog command only; uhdm2rtlil 1740 of 1740; no
  other slang-uhdm binary named.
- trace census (evidence/trace_census.txt): on the law, no trace file from any probe case, surelog,
  uhdm2rtlil or downstream database; sv-tests p203 (clsSpecSurelogOrder436 x4), p334
  (genClsNoDefRangeSyntax436 x4), p719 (nestedModGateUpwardNet436 x45), rsd (ifaceDefArrNetDimSym436
  x386, SURELOG_CRASH, unjudgeable) and apb_protocol_monitor (uninstIfaceAssertListing436 x17,
  cgArrayElemUnsupportedTs436 x1, ifaceDefArrNetDimSym436 x1): the implementer's census exactly.
- determinism: three concurrent ver4 runs of apb_protocol_monitor and of p719 read one hash each.
- the implementer's 71 grid lines reproduced exactly with the law binary once the md5 column is
  stripped (evidence/grid_r11u436_reproduced.txt).
- the earlier-pass census (drivers/census3.sh, evidence/earlier_pass_census_all.txt): 4838
  fence-filtered case dirs of passes 401 to 434 run on pristine, law and ver4 writing one output
  path in turn: exit codes equal on all three binaries; pristine -> law moves exactly the
  implementer's five (r11u408 GC/gc05, v11u408 VG/vg15, v11u424 VI/vi12 and v11u432 VD/vd06 to
  STRICT_EQUAL, v11u424 VP/vp06 NOT_EQUAL dump distance 131 -> 13; evidence/earlier_pass_movers.txt);
  law -> verified moves none.

## THE BREAKS (fresh legal SV, pristine right on the field, the law wrong) and the refinements

Every refinement reads through `src/LawSwitch.h` (`fixOn(436, "R11V436_<X>_OFF")`, `lawTrace(436, ...)`),
`R11V436_OFF` gives the law's bytes on all 198 case dirs of both grids, each refinement's own switch
the law's bytes on its own cases; `R11U436_OFF` still gives pristine's bytes on all 198. No
`src/R*.h`, no getenv, no new include; the refinements touch ModuleEmit and TypeEmit only.

1. **§ cgArrDefNetDimEnd436v** (ModuleEmit materializeDefNetTs, `R11V436_CGDIMEND_OFF`).
   § cgArrayElemUnsupportedTs436 names the covergroup element typespec `cg`, and the def-net end
   writer (`writeEnd171` to the first unpacked dimension) runs only on an unnamed typespec, so a
   MODULE definition net typed by a covergroup array kept the type's own end (`cg c4[4];` 4:1-4:3)
   where golden and pristine's logic_typespec read 4:1-4:9 (fixed, 2-D, queue, dynamic and
   associative dims alike: golden `cg q[$]` 4:8, `cg aa[int]` 4:11, `cg c2[2][3]` 4:9). The kind moved
   toward golden while the end cell moved away. The refinement lets the law's covergroup-element
   unsupported_typespec take the same end. Cases VC vc01 to vc05, vc07 (law -> verified sorted dump
   distance 47 -> 43, 46 -> 42, 12 -> 8, 4 -> 0, 22 -> 18, 15 -> 11) and the implementer's IU/iu09 (4 -> 0)
   and iu13 (22 -> 18); the interface cases (the law's own declaration span) unchanged. Fires on no
   sv-tests, corpus or probe byte (its ver3 trace logged four single-handle databases without
   writing anything, the trace now behind the array test in ver4).
2. **§ nestGateNetInstOwner436v** (ModuleEmit emitGates, `R11V436_NESTGATEOWNER_OFF`). A terminal of
   a GATE ARRAY in a nested module (`and g1 [1:0] (y, a, b);`) has the gate_array as parent, so
   § nestedModGateUpwardNet436 minted the implicit net under the gate_array and listed it nowhere:
   three orphan nets, VN/vn18 pristine 59 -> law 65 dump lines from golden. Golden lists them under
   the nested instance (`vpiParent module_inst work@top.i1`). The refinement walks up to the enclosing
   module_inst for the parent, the listing and the key: vn18 65 -> 26, NOT_EQUAL -> STRICT_NOTEQUAL
   fullname (the gate_array's definition-view name, wrong on pristine too).
3. **§ clsSpecKwlessFirstOrder436v** (TypeEmit makeTypespec, `R11V436_KWLESSORDER_OFF`).
   § clsSpecSurelogOrder436's formal order (a keyword-less TYPE declaration after a `parameter` one
   moves first) is not Surelog's: Surelog's ordered formals are every header declaration written
   WITHOUT `parameter`/`localparam`, type or value, in written order (CompileClass's
   Parameter_port_list loop), then the keyword declarations in written order. Golden
   `#(type T = int, parameter p = 2, type U = int)` with `C#(real, 3, bit)` lists C.T (at T) and C.p
   (Lhs the value formal p): pristine's first entry C.T 2:16 was golden's, the law renamed it C.U
   2:47 (VS/vs01); `#(parameter p = 2, type T = int, int r = 4)` with `C#(1, real, 7)` lists C.r, the
   law wrote C.p (vs16). The refinement orders keyword-less first: vs01, vs16, vs27
   (`#(parameter p, int q, type T, parameter type U)`), vs28 and vs29 (`#(parameter type T, type U)`)
   NOT_EQUAL -> STRICT_EQUAL; the implementer's CS grid is byte-identical (the two rules agree there).

## The attack grid (127 case dirs in VA, VC, VD, VN, VP, VR, VS; evidence/grid_law_vs_pristine.txt,
## evidence/grid_verified_final.txt, evidence/classify_final.txt)

Every case is accepted by upstream slang (`~/.local/bin/slang --single-unit`, drivers/upslang.sh) and
every exit code is 0 on pristine, law and verified. Pristine -> verified: 83 NOT_EQUAL ->
STRICT_EQUAL, 2 STRICT_NOTEQUAL -> STRICT_EQUAL (VN vn06, vn08), 3 NOT_EQUAL -> STRICT_NOTEQUAL (VC/vc03
col, VN/vn18 fullname, VS/vs25 endcol), 19 NOT_EQUAL on both and closer by sorted dump distance, 12
NOT_EQUAL and 7 controls byte-identical, NONE further; vs28 STRICT_EQUAL at an unchanged distance
(the copied golden's path lines). Downstream (drivers/dsgrid.sh) on the 65 class-free VN, VD, VA and
VC cases and the implementer's 29 class-free NM and IU cases with ver4: no verdict change (60 + 27
IDENTICAL, the rest EQUIVALENT or STATUS_DIFF on both).

Cases by law (each case's first line names it):

- § uninstIfaceAssertListing436 VA va01 to va20: named property and sequence references, sequence
  formals, assume, cover property, cover sequence, restrict, disable iff, else action blocks, a
  modport, a wire and an immediate assert beside it, a formal default, a property local variable,
  typed formals called twice, a function call, $rose/$past, an unlabeled assertion, explicit and
  implicit tops, two interfaces with one instantiated (va14 closer), generate-block assertions
  (va16, not reached, byte-identical).
- § cgArrayElemUnsupportedTs436 VC vc06, vc08 to vc12 (single handle, function local, instantiated
  interface, two declarators, class handle array control, generate block); § cgArrDefNetDimEnd436v
  vc01 to vc05, vc07 (queue, dynamic, parameterized covergroup, 2-D, foreach-initialized, associative).
- § ifaceDefArrNetDimSym436 VD vd01 to vd16 (overridden, 2-D, package-scoped bound, localparam,
  int and wire arrays, two instances, generate-instantiated $unit, instantiated only from an
  uninstantiated module with an explicit top, nested interface, typedef, hierarchical write,
  process, a $unit name shadowed by an interface parameter, packed-and-unpacked, initialized nets).
- § nestedModGateUpwardNet436 VN vn01 to vn17 (gate in a generate block, two instances, net declared
  after the nested module, a shadowing local, a doubly nested module, generate-for instances,
  bit-select terminals, an uninstantiated nested module, a variable, two outer instances, a nested
  module with ports, a chained gate, bufif1, a UDP, a delay over an outer parameter, an unnamed
  gate); § nestGateNetInstOwner436v vn18 (a gate array).
- § genClsNoDefPropRange436 VP vp01 to vp16 (bit signed, two declarators, two default-less bounds,
  rand and static, an extending class, a method reading the property, a specialized use, a $unit
  class, a parenthesized bound, reg, an initializer (vp11 closer), packed 2-D, local/protected; a
  class in a module, a defaulted bound and a type parameter abstaining byte-identical).
- § genClsNoDefRangeSyntax436 VR vr01 to vr17 (a defaulted bound, bit signed, packed 2-D, a task
  local, $clog2, a localparam bound, an unpacked local (vr07 closer), an out-of-body method, reg, a
  package class, output and ref arguments, two parameters, a loop-block local, const locals).
- § clsSpecSurelogOrder436 VS vs02 to vs15, vs17 to vs20, vs22 to vs26 (value-only, keyword type,
  function local, typedef, package-scoped, inherited default, two declarators, explicitly typed
  value, comma-continued values, generate block, a named list beside ordered ones, a vector type
  argument, a class argument, a module parameter argument, a typedef argument, `#()`, an import, an
  extending class, an unpacked variable); § clsSpecKwlessFirstOrder436v vs01, vs16, vs27 to vs29.

## Measurement process and slips

- Builds over the budget: the law once (equal md5), then four verified builds: ver1 and ver2
  intermediate (case runs only, each adding a refinement as a break was found), ver3 swept in full,
  ver4 a trace-placement edit of ver3 (the condition `cgArr436v` now also tests the array kind before
  `lawFixOn`, the writer itself already required it): ver4 equals ver3 byte for byte on all 198 case
  dirs, the probe stage rerun alone (4087 dumps identical to ver3's) and CrossFunc in both modes (the
  only corpus rows ver3's trace named), so ver3's full sweep stands for ver4; no third full sweep.
- My first sweep chain was killed by its own PIDs twice before any stage ran: once to swap in the
  third refinement, once because my quiet check matched my own driver's name (a deadlock, not an
  overlap). The sister v11u433 ran its two sweeps in between; none of my builds, grids or stages
  overlapped a sister stage (every launch after three quiet readings, drivers/quiet3.sh).
- The fence list was read into a file by a program without printing it, and every tree-wide list
  (the census path list, the cmds.txt audit) filtered on it before a file was opened; no fenced test
  named, opened or run; no other agent's process touched.

## Residues (all wrong on pristine too, none moved away), ranked

1. The implementer's residue list stands (the 16 other uvm-examples rows, the 3 uvm_scoreboard rows
   and easyUVM, the 8 inv-placeholder basejump rows, p737, tnoc, fx68k and p733 on the sister's
   ground, CS/cs12, DL dl13 to dl15, dl18, dl20 to dl22, NM/nm02, IU iu04, iu10, iu17).
2. The definition-view name of a gate ARRAY in a nested module (VN/vn18: golden
   `work@top.work@top::sub.g1`, ours `work@top::sub.g1`; the law renames single gates only).
3. A gate inside a generate block of a nested module (VN/vn01) and a nested module reading an outer
   variable rather than a net (vn09), a UDP terminal (vn14 closer) and a delay over an outer parameter
   (vn16 closer): not reached.
4. The ordering law's value-argument reference shapes (VS/vs19 `C#(int, W)`, vs20 a typedef
   argument closer, vs22 `C#()`, vs05 a function local and vs13 a generate-block variable not
   reached).
5. A default-less class in a module (VP/vp14), a defaulted bound (vp15), a type parameter beside it
   (vp16); an unpacked method local (VR/vr07 closer).
6. Interface generate-block assertions (VA/va16); the instantiated twin of the covergroup array
   (VC/vc09 closer) and the elaborated foreach loop variable (vc05, the sister's StmtEmit face).

## Sister-ground faces (reported, not written)

- apb_protocol_monitor's last strict field: the left side `APB_protocol_cg[i]` of `= new()` spanning
  the whole select where golden spans the index (ExprEmit's element select under StmtEmit's
  assignment; the implementer's IU/iu12; VC/vc03 STRICT_NOTEQUAL col reads the same face).
- the foreach loop variable written as `int_var` where golden writes `ref_var` (VC/vc05, StmtEmit).
