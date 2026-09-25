# r11v167 — adversarial verification of r11u167 (the expression/parameter ground: six laws on type-parameter struct copies, evalFunc leftovers, generate-scope folds and dotted paths)

Verdict: **ACCEPT-WITH-FIX.** Every headline number of r11u167 reproduces bit-for-bit (binaries, predictions,
conversions, changes, movers, downstream). One break was found on fresh legal SV: § evalFuncBodyRhsStampClone167
makes the exporter **crash** (rc=139 in `UHDM::Serializer::Save`) when the function-body right-hand side it clones
holds a path element other than a plain reference (`r.Flag = c.Length[0] != 0;`, case fb/b07; pristine writes a
judge-equal database). The fix, § s2ClonePrecheck167v (`R11V167_S2PRECHECK_OFF`), checks that the whole tree can be
cloned before the clone allocates anything. Where it cannot, the share is kept, which is pristine's database. It
fires on no corpus row and no probe case: the census predictions of the verified binary equal the law binary's
(58 names), and the verified gate sweep's csvs equal the law sweep's (the verified-vs-law byte movers are the UVM
order coin alone). The verified patch is /tmp/r11u167.verified.patch.

Base `576b21fa`. Worktrees `/tmp/wt_v11u167pris` (pristine) and `/tmp/wt_v11u167` (the law patch, then the fix).
System-deps configuration, `-j 2`.

| binary | md5 |
|---|---|
| pristine (worktree build of the base; = the main tree's build/slang-uhdm) | `2a705713aa2d9ba859d3fd83eaa95ed7` |
| law (r11u167.patch, md5 `91e0d1ba0501b3945e83ab9f3d27f706`) | `a56d01dffa006e046c84f4ac844d63c3` (= the implementer's) |
| verified (r11u167.patch + § s2ClonePrecheck167v) | `897c5ab1b4073bc00308ac17d99e5db2` |
| build/uhdm-strictcmp | `5d4617d0458f34aa79e0b91009d5d1fc` |

Every binary was frozen (`chmod 555` copies) before it was measured. The sweep workdirs `/tmp/v11u167_sw{P,L,V}`
have names of the same length. Each sweep's `cmds.txt` names its own frozen copy: 1531 of 1581 surelog and 1742 of 1742
uhdm2rtlil files. The other 50 hold no slang line (SURELOG_FAIL and the like), in every sweep.

**The fence.** Every driver reads `$FENCED` and refuses to run without it. The censuses dispatch the corpora with a
negative-lookahead `--filter` that excludes the four fenced tests, and both read "fenced mentions: 0". No fenced
source or database was read. A grep of this directory for the four names reads 0.

## Reproduction of the implementer's numbers

| claim | reproduced |
|---|---|
| pristine = base: probe EQUAL 2597 / STRICT_NOTEQUAL 1490; surelog 437+43 / 434+40; uhdm2rtlil 769+34 per mode; downstream 803/66/2 | yes; pristine probe.csv byte-identical to results/golden_probe.csv; all three stages regressions=0 conversions=0 changes=0 |
| census prediction: 58 names (11 surelog, 4 uhdm2rtlil, 43 probe) with the laws that fire | yes; predict.py output byte-identical to the implementer's evidence/predicted_movers.tsv |
| law sweep probe: regressions=0 conversions=29 changes=13, EQUAL 2626 / STRICT_NOTEQUAL 1461 | yes |
| law sweep surelog: regressions=0 conversions=4 changes=2 | yes |
| law sweep uhdm2rtlil: regressions=0 conversions=4 changes=0 | yes |
| downstream: 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT, byte-identical to pristine | yes; the law and the verified downstream.csv are byte-identical to the pristine sweep's and to results/downstream_uhdm2rtlil.csv |
| byteverify: surelog 16 movers (11 predicted + 5 coin), uhdm2rtlil 4 (all predicted), probe 43 (all predicted) | surelog 16 = the 11 predicted + 5 coin (MiniAmiq d/t, SeqDriver d/t, Scoreboard d: this run's draw); uhdm2rtlil 4/4 predicted; probe 43 = the 43 predicted (dump-normalised, the two sweeps ran from different worktrees) |
| `R11U167_OFF`: pristine bytes on the pass's and 13 prior passes' cases | 1231/1231 on the verified binary (the implementer's 56, these 67, the 1108 of r11u163 r11v163 r11u158 r11v158 r11u154 r11v154 r11u131 r11v131 r11u124 r11v124 r11u160 r11u120 r11v120) |
| laws on: the 1108 prior-pass cases byte-identical to pristine | 1108/1108 on the verified binary |
| each switch alone restores its own cases | 65 cases fire exactly one law: its switch alone restores pristine bytes on all 65 (evidence/switches.txt) |

The fresh rows of the targeted conversions (verified sweep; law sweep identical):

    surelog     StructParamFieldRange,default,CMP_EQUAL,,,equal              (base differ:fullname(7))
                StructParamFieldRange,testflags,CMP_EQUAL,,,equal
                StructParamFuncBodyFieldCompare,default,CMP_EQUAL,,,equal    (base differ:fullname(11))
                StructParamFuncBodyFieldCompare,testflags,CMP_EQUAL,,,equal
    uhdm2rtlil  cva6_struct_param_field,default,CMP_EQUAL,,,equal            (base differ:fullname(7))
                cva6_struct_param_field,testflags,CMP_EQUAL,,,equal
                ibex_register_file_ff,default,CMP_EQUAL,,,equal              (base differ:fullname(31))
                ibex_register_file_ff,testflags,CMP_EQUAL,,,equal
    downstream  cva6_struct_param_field,IDENTICAL,OK,OK,1,1,,
                ibex_register_file_ff,IDENTICAL,OK,OK,3663,3663,,
    changes     StructParamPatternInitCast d/t differ:fullname(11) -> differ:fullname(3)

The base heads were reproduced with the raw-name comparator (`tools/probe/r11u167repro/drivers/mkstrictraw.sh`):
StructParamFieldRange `#159 ref_typespec <in>x{work@StructParamFieldRange.I.x}` against ours `{x}` and `#180
struct_typespec 23:26-23:32` against ours `23:26-26:4`; ibex_register_file_ff `#658 ref_obj DataWidth
{work@ibex_register_file_ff.DataWidth}` against ours empty; StructParamPatternInitCast `#67 ref_typespec` golden
unnamed, ours `cfg_pkg`.

Probe changes: all 13 lose records. The three whose first field moved keep the field that pristine already had
later in the walk. r11u109 p03 goes `fullname(8) -> type(1)`: pristine had type=1 and 8 objects, verified has 1.
p06 and p07 go `fullname -> value(2)`: pristine had value=2, and 13 and 9 objects become 2
(evidence/probe_changes_V_vs_P.txt).

Canaries: r11u107repro/canaries.sh reads surelog ok=50 changed=2 and uhdm2rtlil ok=16 changed=0 on the pristine,
law and verified csvs alike. The two changes are the Earlgrey_0_1 d/t dump-column draw (`line(1686) -> line(1730)`),
an environment draw that appears identically on pristine. ctcan2.sh `EXPECT_UNKNOWN=1` (surelog) and
`EXPECT_UNKNOWN=6` (uhdm2rtlil) PASS on all three.

## The break: § evalFuncBodyRhsStampClone167 crashes on a non-plain path element (case fb/b07)

`r.Flag = c.Length[0] != 0;` in the function body. cloneStampTree167 copies the operation, then meets the
bit_select path element of `c.Length[0]`. It sets `ok = false` and returns nullptr into the operand vector of the
operation it has already made. The caller keeps the share (correct), but the orphan operation stays in the
Serializer's factory, and `UHDM::Serializer::Save` dereferences its null operand (gdb:
`SaveAdapter::operator()<UHDM::operation, ...>` <- `Serializer::Save` <- `realMain`; evidence/b07_crash.txt).
Pristine rc=0, uhdm-cmp 0 lines, STRICT_NOTEQUAL fullname. The law gives rc=139 and no database, and the downstream
lane would read SLANG_REJECT. `R11U167_S2CLONE_OFF=1` alone restores rc=0. Any other failed clone also leaves orphan
objects in the written file: they are invisible to the judge, but they change the bytes.

**§ s2ClonePrecheck167v** (`R11V167_S2PRECHECK_OFF`; ParamEmit.cpp, `stampTreeClonable167v` and its use in
stampEvalFuncLeftovers, under `R11U167_OFF` like every r11u167 law): before any copy is made, every S2 value of
the parameter's struct must be a tree of operations, hier_paths whose elements are all ref_objs, ref_objs and
constants. This is the kind set cloneStampTree167 copies. Otherwise the parameter keeps the share and the law
traces `s2ClonePrecheck167v skip`. On fb/b07 the verified database is byte-identical to pristine. On every other case
of both grids the verified database is byte-identical to the law's. The census over both corpora and the probe cases
finds no firing of the skip, so the verified sweep changes no verdict and moves no byte outside the coin
(verified vs law: surelog 6 movers, all MiniAmiq/SeqDriver/SimpleUVM/Scoreboard, 4/4/4/0 order-blind lines of
UINT/vpiDecompile; uhdm2rtlil 0; probe 0 of 4087).

## Gates (verified binary)

| gate | result |
|---|---|
| (1) build | pristine `2a705713…` = main tree; verified `897c5ab1…` |
| (2) probe | regressions=0 conversions=29 changes=13; EQUAL 2626 STRICT_NOTEQUAL 1461; probe.csv byte-identical to the law sweep's |
| (3) surelog, uhdm2rtlil | regressions=0; conversions 4 + 4; changes 2 + 0; the csvs equal the law sweep's (surelog differs only in the LowMem workdir text) |
| (4) downstream | EQUIVALENT=2 IDENTICAL=803 SLANG_REJECT=66, not identical and not excused=0; downstream.csv byte-identical to pristine's and to the committed baseline |
| (5) uhdm-cmp | no corpus row or probe case leaves judge-equality; every fresh case keeps its uhdm-cmp verdict except hw/h01-h06 h08 h09, which go from stage 1 to 0 lines |
| (6) byteverify vs pristine | surelog 17 = 11 predicted + 6 coin (MiniAmiq d/t, SeqDriver d/t, SimpleUVM d/t: 4/4 order-blind UINT/vpiDecompile lines each, evidence/uvm_coin_verified.txt); uhdm2rtlil 4/4 predicted; probe 43/43 predicted |
| strict column, row by row, verified vs pristine | only the 8 conversions and the 2 StructParamPatternInitCast changes (surelog, uhdm2rtlil); probe 29 conversions + 13 changes, all counts down |

## Fresh grids (67 cases, `cases/`; pristine -> law -> verified in evidence/grid_PLV.txt)

Each case names its law in its first line. Verdicts are judged by uhdm-cmp and uhdm-strictcmp against the v1.87 pin
(drivers/grid.sh), and by the downstream harness (drivers/dsgrid.py, evidence/downstream_fresh_P_V.txt).

| grid | law | cases | pristine -> verified |
|---|---|---|---|
| ts | § tpAnonStructLastParamUser167 + § tpAnonStructCopySpanAtKeyword167 | t02 (header value parameter + body localparam), t03 (signed struct), t06 (a `'0` user then a pattern user), t07 (two type parameters), t10 (header type, two instances), t16 (macro-born struct), t17 (two modules with the same type name), t19 (header union) | fullname -> STRICT_EQUAL |
| ts | § tpAnonStructCopySpanAtKeyword167 | t04 (a port of the type: span half alone) | endcol -> STRICT_EQUAL |
| ts | § tpAnonStructCopySpanAtKeyword167 | t08 (`$bits(it_t)` names the type again, so the parent half abstains and only the span half fires) 7->4 objects, t13 (two declarators in one declaration: the token count abstains, span half only) 10->4 | records leave, none enter; the member references golden names through the last value parameter stay (residue 5) |
| ts | § tpAnonStructLastParamUser167 | t09 (nested anonymous member: the inner members' references keep `x.h`, residue 5) 11->4 objects, t14 (under a generate block: the one left is `work@top.g.u` against `work@top.u`, a pre-existing face) 8->1, t11 (`[W:1]` member range) 12->1 with first field `type` (pristine's own later record) | records leave, none enter |
| ts | § tpAnonStructLastParamUser167 | t01 t05 t12 t15 t18 | stage 1 on both |
| pa | § pkgPatCallArgReadNoParent167 | a07 (`$clog2(p::B.XLEN)`) 2->1 objects; a12 a13 a14 a15 (stage 1 on both; the package listing's pattern reference moves from `(p)` to unnamed, which is golden's at that dump position); a01-a06 a08-a11 | toward golden or unchanged |
| fb | § evalFuncBodyRhsStampClone167 | b05 (a nested instance), b08 (a single comparison) | fullname -> STRICT_EQUAL |
| fb | § s2ClonePrecheck167v | **b07 (bit_select path element: law rc=139)** | pristine verdict, pristine bytes |
| fb | § evalFuncBodyRhsStampClone167 | b01 (instance under a generate block: walk167 does not enter generate scopes, unchanged), b04 (a struct_var of the type: 4 -> 4 objects, the clone is named `cfg_pkg::cfg_t.Flag.NrRules` where golden has `work@top.Cfg...`; the canonical walk reads equal tails, residue), b02 b03 b06 stage 1 on both | unchanged |
| gf | § genProcFoldDeclTsScopeNamed167 | g02 (signed), g04 (`[W:1]`), g05 (two parameters), g07 (in a comparison), g08 (always_comb, two reads), g09 (`p::PW` under an operation), g11 (a generate-for), g12 (two instances, one overriding) | fullname -> STRICT_EQUAL |
| gf | § genProcFoldDeclTsScopeNamed167 | g01 (a literal range), g03 (nested generate blocks), g13 (`top.Z`) | equal -> equal (controls) |
| gf | § genProcFoldDeclTsScopeNamed167 | g06 (`$clog2(W)` bound: the law does not fire, residue 3), g10 (a generate-local localparam: the pre-existing endcol face) | unchanged |
| hw | § hpDotWsTrimmed167 | h01 (one side), h02 (newline), h03 (interface array element), h04 (procedural), h05 (three components through a module instance), h06 (tabs), h08 (read and write), h09 (module-instance variable) | stage 1 -> STRICT_EQUAL; downstream STATUS_DIFF (slang lane READ_FAIL) -> IDENTICAL |
| hw | § hpDotWsTrimmed167 | h07 (`bs . wdtxx[3:0]`: a selected leaf), h10 (a comment inside the path), h11 (an escaped identifier: the law abstains), h12 (`bs[ I ] . wdtxx`) | stage 1 on both; h07 h10 h12 downstream READ_FAIL on both (residue) |

Downstream on the fresh cases, pristine -> verified: 50 IDENTICAL -> IDENTICAL, 7 STATUS_DIFF -> IDENTICAL (the hw
cases above), 5 EQUIVALENT -> EQUIVALENT, 4 STATUS_DIFF -> STATUS_DIFF, 1 DIVERGENT -> DIVERGENT (h11). No case
moves away from IDENTICAL.

## Ranked residues (added by this verification; the implementer's list stands)

1. The dotted-path whitespace outside the HierarchicalValue branch: a selected leaf (`bs . wdtxx[3:0]`, h07), blanks
   inside an index (`bs[ I ] . wdtxx`, h12) and a comment (`bs /* c */ . wdtxx`, h10). The part_select is still
   named ` wdtxx` (`work@top.bs . wdtxx[3:0]. wdtxx`), the plugin cannot read the database (READ_FAIL), and without
   the blanks both shapes are STRICT_EQUAL. ExprEmit.cpp has 19 hier_path construction sites, and
   § hpDotWsTrimmed167 covers the one after the component split.
2. § evalFuncBodyRhsStampClone167 does not reach an instance under a generate scope (fb/b01, `walk167` descends
   only `Modules()`). With a struct_var of the type in the module (fb/b04), the elaborated copy's references are
   named without the parameter prefix.
3. § genProcFoldDeclTsScopeNamed167 does not fire on a declared range bounded through a system call
   (`[$clog2(W)-1:0]`, gf/g06): the reference `W` keeps no name where golden has `work@top.W`.
4. § pkgPatCallArgReadNoParent167: the stage-1 heads of the pa grid (a01-a06, a08-a15). These are the
   package-pattern-through-a-call family, which is outside this pass.
5. § tpAnonStructLastParamUser167's parent half abstains when the type is named again (`$bits(it_t)`, t08) or
   when two declarators share one declaration (t13), and it clears only the top-level members' reference names (a
   nested anonymous member keeps `x.h`, t09).

## Files

* drivers/grid.sh, gridall.sh (one case / all cases: golden, ours, uhdm-cmp, uhdm-strictcmp), bytes.sh (byte
  controls, `R11U167_OFF` bytes), switches.sh (each switch alone), dsgrid.py (downstream verdict per case),
  census.sh + tracewrap.sh + predict.py (the fence-filtered firing census and the predicted set; after r11u167's),
  rowcmp.sh (one corpus row's raw strict records), audit.sh (cmds.txt binary audit), pdump.sh (dump-normalised probe
  mover check), sweep.sh (the gate sweep with the frozen binary).
* evidence/: grid_PLV.txt, downstream_fresh_P_V.txt, switches.txt, offbytes.txt, ctl_verbytes.txt,
  predicted_law.tsv, predicted_verified.tsv, byteverify_law_vs_pristine.txt, probe_movers_law.txt,
  probe_changes_V_vs_P.txt, uvm_coin_law.txt, uvm_coin_verified.txt, b07_crash.txt.
