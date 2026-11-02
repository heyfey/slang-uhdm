# r11u467: every design copy of a $unit-imported package parameter owns its typespec reference

Pass 467, the expression/parameter ground (src/ParamEmit.cpp only). Base 1dd2079d. One law.
The pristine binary is the worktree's first build: md5 f679bd99637c44cb0c5098ebcfbf1f7e, the same
as the main tree's build/slang-uhdm. The law binary law1 has md5 c9b2f893019899967f666555de7bc9e8
and links slang 12.0.0+545f88b2e. law1 is the final binary and the one swept.

## Target row: generated/uvm-examples/uvm_many_to_one.sv

**STRICT_NOTEQUAL differ:fullname(200) -> EQUAL.** It was the last STRICT_NOTEQUAL row. Fresh sweep row
(evidence/svtests_converted_row.txt):

    generated/uvm-examples/uvm_many_to_one.sv,EQUAL,,equal

How the head was found:

- uhdm-strictcmp on the pristine pair (evidence/rows/many_to_one_strict_pristine.txt) lists 200
  records, all `fullname`. Each one is the depth-3 ref_typespec under a parameter that is the Lhs of
  one of the **design's** param_assigns. These are the copies of the 40 uvm_pkg parameters
  (UVM_HDL_MAX_WIDTH, UVM_VERSION_STRING, ... UVM_LARGE_STRING) that test.sv's file-scope
  `import env_pkg::*;` lists. Golden writes `UVM_HDL_MAX_WIDTH` and ours writes
  `env_pkg::UVM_HDL_MAX_WIDTH`.
- The design lists UVM_HDL_MAX_WIDTH 8 times: once for uvm_pkg, 6 times for env_pkg's per-path
  repeats (§ diamondImportParamAssignsPerPath451) and once for a_pkg. In golden, every copy's
  ref_typespec is its own object, parented at the copy and named bare. In ours, the uvm_pkg copy, the
  first env_pkg copy and the a_pkg copy own their reference, and the 5 later env_pkg copies
  share the reference of env_pkg's own per-path parameter (parent package env_pkg, so the name is
  `env_pkg::...`). See evidence/rows/many_to_one_design_copies.txt (evidence/tools/dpa.cpp).
  Those 5 copies times 40 parameters are the 200 records.
- The writer: UhdmExporter's § unitImportHoistsPkgParams146 (designImportPaCopy146) shares the
  source parameter's reference. UhdmExporter's § unitImportCopyOwnTsRef214 then gives a private
  reference only to a copy that shares the **first** same-named parameter of the package, because
  its source map is an emplace. The per-path repeats of § diamondImportParamAssignsPerPath451
  (this ground, ParamEmit) are separate parameter objects, so their copies never match.
- The law is written here. It runs inside ParamEmit's design-final drainPaNameCopySrc38, which
  runs after § 214 (as § cloneLvSharesHomeUnitTs465 does). The objects it repairs are the
  copies of ParamEmit's per-path repeats.

## Law (src/ParamEmit.cpp, read through src/LawSwitch.h; R11U467_OFF drops it; R11U467_TRACE=<dir>)

1. **§ unitCopyOwnTsEveryPath467** (`R11U467_UNITCOPYTS_OFF`).
   - Statement: every design-listing copy of a `$unit`-imported package parameter holds its own
     typespec reference, including the copies of a package's per-path repeats.
   - Surelog: CompileHelper::importPackage (third_party/Surelog/src/DesignCompile/CompileHelper.cpp,
     its "Regular parameter" loop) clones each param_assign of the imported package's
     getParamAssignVec(). That vector has one entry per import path. It uses UHDM::clone_tree, so
     every design copy is a new parameter whose ref_typespec is a fresh clone with no stored full
     name. ComputeFullName reads the copy's chain, which is the bare parameter name under the
     design.
   - Rule, design-final (the end of drainPaNameCopySrc38): a design copy (vpiImported set) that
     still shares the reference of **any** same-named parameter of its package's listing
     (vpiParameter entries and param_assign left sides) gets the same private reference that
     § 214 gives. A typedef'd chain goes through § unitImpTdParamTsClone402's impTsChain402
     first. Otherwise it gets a plain ref_typespec parented at the copy, over the same actual.
   - Trace: `unitCopyOwnTsEveryPath467 <pkg>::<name>` per firing.
   - No src/R*.h, no LawState.h section, no getenv, no header change. ExprEmit, StmtEmit,
     EmitHelpers.h and every sister file are unchanged. The law calls ModuleEmit's existing
     non-static impTsChain402 through a local declaration.

## Grid (cases/UC; every first line `// § unitCopyOwnTsEveryPath467`; evidence/grid.txt)

Every case is accepted by upstream slang (exit 0) and exits 0 on both binaries.

| case | law | shape | pristine -> law1 | dump distance |
|---|---|---|---|---|
| UC/uc01 | unitCopyOwnTsEveryPath467 | c imports a and b (b imports a), `import c::*;` at file scope | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 380 -> 366 |
| UC/uc02 | unitCopyOwnTsEveryPath467 | the same with a typedef'd parameter (impTsChain402 branch) | NOT_EQUAL 690 -> NOT_EQUAL 690 (bytes move) | 1297 -> 1284 |
| UC/uc03 | unitCopyOwnTsEveryPath467 | three paths, plus a direct `import a::*;` | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 266 -> 252 |
| UC/uc04 | unitCopyOwnTsEveryPath467 | the paths in the other order, one untyped parameter | STRICT_NOTEQUAL fullname -> **STRICT_EQUAL** | 257 -> 243 |
| UC/uc05 | unitCopyOwnTsEveryPath467 (control) | the diamond imported inside the module | STRICT_EQUAL, byte-identical | 106 -> 106 |
| UC/uc06 | unitCopyOwnTsEveryPath467 (control) | a single path | STRICT_EQUAL, byte-identical | 50 -> 50 |

- uc02's uhdm-cmp head is an older face, not this law's. It reproduces with a single path and no
  diamond (282 lines on pristine). It is pass 453's typedef-typed re-exported package parameter
  family (TS/ts02).
- Switch check (evidence/switchcheck.txt): R11U467_UNITCOPYTS_OFF=1 and R11U467_OFF=1 each give
  pristine's bytes on all 6 dirs.
- Downstream: uc01 and uc03 read IDENTICAL on both binaries (no gates).

## Prediction (written before the sweep: evidence/prediction.txt)

- Database census: evidence/tools/pred.cpp is the law's predicate. It ran over all 7482
  fence-filtered slang databases of the master's control /tmp/intr11u465.
  - Positive controls: uc01 to uc04 fire, uc05 and uc06 do not, and pristine many_to_one fires 200.
  - Firings: only sv-tests uvm_many_to_one (200) and rsd (1198193).
- sv-tests text census plus a traced run of law1 over 226 candidate rows: the same two rows fire,
  with the same counts.
- Predicted outcome: many_to_one -> EQUAL; rsd moves bytes (SURELOG_CRASH, no golden); 0 movers in
  probe, surelog, uhdm2rtlil and downstream; 0 exit-code movers.

## Gates (one full five-stage sweep on law1, workdir /tmp/r11u467_sw)

The corpora ran from the worktree (rc 0). The sv-tests stage ran through the main tree's
tests/sweep.sh, because the worktree's UVM folder is empty. It exited 1 only on the main tree's
stale law index.

| stage | result |
|---|---|
| probe | EQUAL 4024 + STRICT_NOTEQUAL 63; regressions 0, conversions 0, changes 0; csv identical to the control |
| surelog | default 480 + 0, testflags 474 + 0; 0/0/0; csv identical to the control after path normalization |
| uhdm2rtlil | 803/1/67 in both modes; 0/0/0; csv identical to the control |
| downstream | IDENTICAL 803 / SLANG_REJECT 66 / EQUIVALENT 2 / DIVERGENT 0; not excused 0; csv identical to the control |
| svtests | EQUAL **1931**, STRICT_NOTEQUAL **0**, DIFFERENT 9, SURELOG_ONLY 75, BOTH_REJECT 303, SLANG_ONLY 19, SURELOG_CRASH 8, TIMEOUT 1 of 2346; regressions 0, **conversions 1** (uvm_many_to_one STRICT_NOTEQUAL -> EQUAL), changes 0 |

Other checks:

- **byteverify** against the control (evidence/byteverify.txt), SELFCHECK on:
  - surelog 0 of 962, uhdm2rtlil 0 of 1608, downstream 0 of 805.
  - probe: 4087 of 4087 identical by path-normalized uhdm-dump. Raw bytes carry the worktree's
    case paths; the negative control is flagged.
  - sv-tests: the 30 re-kept databases all differ in raw bytes. 29 are STRICT_EQUAL to the
    control under `uhdm-strictcmp --no-canon` (the serialization-order variance). The 30th is
    rsd, STRICT_NOTEQUAL fullname: 21977 objects, the law's bare names, which is the predicted
    mover. Its status stays SURELOG_CRASH.
- **Sweep trace** (evidence/sweep_trace_firings.txt): exactly the predicted two processes, many_to_one 200
  and rsd 1198193.
- **Canaries**: ok=52 and ok=16; ctcan2 PASS on both (evidence/canaries.txt).
- **Binary audit**:
  - surelog: 1531 of 1581 cmds.txt name law1, and the other 50 hold only a Surelog line.
  - uhdm2rtlil: 1742 of 1742. sv-tests: 2346 of 2346.
- **Byte check** of 9094 earlier case dirs (r11u14*, r11u21*, r11u40-46* and their v11u twins;
  evidence/bytecheck_earlier_cases.txt), pristine against law1:
  - 9016 exit-0 dirs and 41 exit-4 dirs are byte-identical.
  - 37 exit-3 dirs differ, but every one also differs between two pristine runs (partially
    written output).
  - 0 exit-code movers.
- uhdm-cmp reads 0 lines on many_to_one and on every touched UC case except uc02, which is
  unchanged at 690.

## Goal 1

- Every one of the 75 SURELOG_ONLY rows carries a slang front-end `error:` diagnostic. No rejecting
  row carries the exporter's own `unsupported` message. Nothing on this ground.
- The probe faces C::mk().arr[1] and u.mk(x).a[2] exit 4 (`element select base`).
  this.mk().inner.s exits 0. Upstream slang accepts all three (exit 0). Surelog rejects all three
  with a syntax error (exit 3), so golden has no shape, and they stay unforced.
- Black-parrot: bp_unicore alone on law1 with the size guard on exits 3 in 12.7 s at a maximum RSS
  of 834 MB (evidence/blackparrot_unicore.txt). There is no memory-bounded export, so the guard
  stays.
- rsd is SURELOG_CRASH and not this ground's.

## Residues (ranked; all wrong on pristine too, none moved away)

1. The open both-accepted rows at the base after this pass are all on the sister's ground or
   awaiting the user: uvm_use_models_pipelined_get_put (ModuleEmit's uninstantiated-interface typedef
   listing), uvm_param_vif_config_db (this_t / transitive class-specialization typedefs), the 3
   uvm_scoreboard rows (the design listing: uhdm-cmp head `LHS: <null>` at the design's include-file
   listing), easyUVM (class_defn work@sequencer's variable listing, UhdmExporter), p737 (the
   builtin package listing), p733 (defparam) and tnoc (333:14): await the user's decision.
2. uc02: the typedef-typed package parameter imported through a second package fails uhdm-cmp
   even on a single path (pass 453's TS/ts02 family). It is not decoded.
3. The carried lists of passes 465 and earlier. The pass 458 union cases LT/lt02, lt06 and
   VB/vb13 still read NOT_EQUAL at 386, 386 and 746 uhdm-cmp lines. Their head pairs golden's
   package p (which lists the union clone with vpiInstance ap) against our package ap. It is not
   decoded.

## Sister-ground faces (reported, not written)

- UhdmExporter § unitImportCopyOwnTsRef214's source map keeps only the first same-named package
  parameter. This pass repairs the leftover copies after it, from ParamEmit. If the sister
  rewrites § 214 to key every same-named parameter, this law stops firing (it is idempotent with
  such a change).
- easyUVM's class_defn variable listing and the scoreboard rows' design listing (UhdmExporter).

## Process

- One law build after the worktree's pristine build.
- One traced 226-row runner census and one single-row runner call on each binary for
  many_to_one, then one full five-stage sweep on law1 and one byteverify against the master's
  control. Each was launched with no sweep or runner process live.
- No pristine sweep.
- The fence list was read into a file by a program and never printed. Every tree-wide list
  (control databases, sv-tests rows, earlier case dirs) was filtered on it before opening. 11
  control paths were dropped by the substring filter and never opened.
- No other agent's process was touched.
