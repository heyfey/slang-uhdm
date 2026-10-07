# r11u270 — the expression/parameter ground: SeqDriver CONVERTS, MiniAmiq reduced to one sister-ground face

Pass 270 (implementer), base 8454e9ff (pass 268 on top of pass 271). Production files: `src/ExprEmit.cpp`,
`src/ParamEmit.cpp`, `src/StmtEmit.cpp`, new `src/R270.h`. Binaries: pristine md5 4473d181 (identical to the main
tree's build), law md5 52efc588 (frozen before every measurement below).

## Verdict per targeted row

| row-mode | base (pristine sweep) | law sweep | what moved |
|---|---|---|---|
| **SeqDriver default** | `STRICT_NOTEQUAL differ:fullname(6)` | **`CMP_EQUAL equal`** | CONVERTED: the six inside-set records (§ insideSetParamFoldKeepsPa270) |
| **SeqDriver testflags** | `STRICT_NOTEQUAL differ:fullname(6)` | **`CMP_EQUAL equal`** | CONVERTED, the same |
| MiniAmiq default | `differ:fullname(4)` | `differ:col(2)` | #227043 / #227046 / #227049 cleared (§ insideSetParamFoldKeepsPa270); the walk divergence #227149 cleared (§ enumAliasCastBindsImportCopy270); the walk then ran to the end of the design and showed 24 more records, of which 22 are cleared by this pass (§ sysCallTimeKwNameSpan270 19, § scopedCallPrefixEndsAtColons270 1, § methArgPathIdxAtHierPath270 2). The 2 left are on the SISTER ground (TaskFuncEmit, below) |
| MiniAmiq testflags | `differ:fullname(4)` | `differ:col(2)` | the same |

Fresh csv rows (law sweep `surelog.csv`):

```
SeqDriver,default,CMP_EQUAL,,,equal
SeqDriver,testflags,CMP_EQUAL,,,equal
MiniAmiq,default,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)
MiniAmiq,testflags,STRICT_NOTEQUAL,differ:col(2),,differ:col(2)
```

MiniAmiq's two remaining records (`evidence/miniamiq_default_heads_law.txt`), ONE face on the sister ground:

```
#241741 col   class_var  svaunit_pkg::svaunit_immediate_assertion_details::new  golden 43:23-29  ours 43:30-34
#243118 col   class_var  svaunit_pkg::svaunit_immediate_assertion_info::new     golden 37:23-29  ours 37:30-34
```

Decoded (not written): a class constructor's return `class_var` is located by Surelog's
`CompileHelper::compileClassConstructorDeclaration` (src/DesignCompile/CompileStmt.cpp) at
`varId = Sibling(Child(first Tf_port_item))`: with no direction keyword the first child is the data type and the
sibling is the formal's NAME (what ours writes), but `function new(input string name = ...)` puts the direction
first, so the sibling is the DATA TYPE (`string`, 23-29); `input a` (implicit type) gives the empty implicit-type
node, zero-width at the name. Ours: TaskFuncEmit, the constructor block (`setLoc(rv, nameSpan(args0[0]->location,
args0[0]->name))`). Reproduced by `cases/C/c01_input_kw` (d1 `input string`, d3 `input int`, d4 `input a` differ;
d2 and base without `input` agree), both views. **With that one sister-ground fix MiniAmiq d/t should read 0 records.**

## The laws (src/R270.h: each law reads its own `R11U270_<LAW>_OFF`; `R11U270_OFF` drops all and gives pristine's
bytes on 118 of 118 grid case-views; `R11U270_TRACE=<dir>` logs every firing, abstention and switched-off firing)

### § insideSetParamFoldKeepsPa270 — switch `R11U270_INSIDEPA_OFF`; refinement § insideSetQualKeepsOp270, `R11U270_INSIDEQUAL_OFF`

ExprEmit (the `Inside` branch records, `insideSetParamPaDrain270` applies design-final from ParamEmit
`drainPaNameCopySrc38`) and StmtEmit (the case-inside item branch records). Surelog's `compileExpression`, the
`paINSIDE` branch (src/DesignCompile/CompileExpression.cpp), pushes every set member as `compileExpression` returns it
and, unlike every other binary operand (`opR->VpiParent(operation)` right below), never re-parents it. A parameter
read the compiler substitutes comes back as `clone_tree(param_ass->Rhs())` with `result->VpiParent(param_ass)`, the
param_assign of the COMPONENT the read is compiled in (the module / interface / program definition, a class's import
copy), so the ref_typespec under the constant is named after that component (`work@top`,
`adpcm_pkg::adpcm_seq_item`, `svaunit_pkg::svaunit_reporter`) where ours, parented at the inside operation, read the
subroutine's (`...::__m_uvm_field_automation`). The law moves a DIRECT member constant (or a plain member of an
open-range set, or a case-inside item) folded from a bare-name parameter, still parented at its operation, to the
param_assign of that name in the first module / interface / program / class / package up the operation's chain, and
names its ref_typespec after that component. No such param_assign: abstain (trace). Records kept in a fixed array (no
heap traffic during emission). The refinement (found on v11u271repro VN/vn19 by this pass's own byte controls before
delivery): a QUALIFIED member `pk::PQ` goes through Surelog's package-scope branch and golden keeps it at the operation;
the law abstains on anything but an IdentifierName.

### § enumAliasCastBindsImportCopy270 — switch `R11U270_ENUMALIAS_OFF`

ExprEmit (the explicit-cast branch records a cast to a package enum-ALIAS typedef bound to an object whose
Typedef_alias has no actual) + ParamEmit `drainPaNameCopySrc38` (rebinds). ParamEmit emitPackage's enum-alias branch
builds the definition-pass clone of `typedef sev sev_t;` with an empty Typedef_alias and binds it only in a TOP pass
the home package never reaches (the home package never lists an alias typedef); emitPackage's import-copy branch states
the model: "An enum-ALIAS typedef gets exactly ONE typespec object in the design" — the import copy
(`pkgImportCloneTs`), which a declaration of the type already binds. A cast written in a class method emitted in
between bound the unlisted clone: MiniAmiq #227149 `uvm_severity_type'(severity)` in svaunit_reporter
`compose_message`, the WALK DIVERGENCE (golden expands the alias target `uvm_severity`, ours read an empty alias ref).
The drain rebinds such a cast's ref_typespec to the import copy when that copy has a bound alias; else abstain
(trace). (A first draft that instead bound the clone's own alias at the TOP pass was measured not to fire: the TOP
pass never reaches the clone; a second draft that looked the listing up through the clone's parent abstained because
that parent is written later by ModuleEmit's enumImportParentDrain180. Neither was swept.)

### § sysCallTimeKwNameSpan270 — switch `R11U270_TIMEKWSPAN_OFF`

ExprEmit (the system-call branch). `$time()` / `$realtime()` written with an empty argument list span their NAME alone:
Surelog's grammar spells them as KEYWORD system names (SV3_1aParser.g4 `system_task_names`: `DOLLAR TIME`,
`DOLLAR REALTIME`, beside `$signed` / `$unsigned`). Golden `$time()` 81:27-32 (MiniAmiq, 19 records per mode);
`$time ()` and `if ($time() > 5)` alike; a Simple_identifier name (`$urandom()`, `$random()`, `$display()`) keeps
the whole call (T/t05).

### § scopedCallPrefixEndsAtColons270 — switch `R11U270_SCOPEDEND_OFF`

ExprEmit `splitScopedName12` (§ staticScopedCall12's span). The class-scope ref_obj ends after the LAST `::` token,
not at the final identifier: whitespace or a line break between them is outside it (golden MiniAmiq #434285
`svaunit_concurrent_assertion_info::type_id::` 239:55-239:99 with `create` on line 240; ours 240:13). Written without
whitespace the two ends coincide (no byte moves). The trace fires in the helper, so it also fires on the
package-qualified select readers that call the helper without using the end (probe r10earl41repro/v41v_comment, 2
firings, no byte moves: the one over-prediction of the census).

### § methArgPathIdxAtHierPath270 — switch `R11U270_MARGIDXPARENT_OFF`

ExprEmit, inside § methodArgNestedRefChain201's design-final loop. A reference that INDEXES a select which is a
path element of a hier_path inside a method call's argument, with a later path element FOLLOWING the select
(`v.exists(v.sva_info[index].get_name())`, `v.has(v.arr[j].k)`), is parented in golden at that hier_path (measured
on every shape of N/n04), so the reader's chain names it after the call: golden
`...::get_sva_tested::vpi_vif.sva_exists::index` (MiniAmiq #245813 / #245818), ours `...::vpi_vif.sva_exists::
vpi_vif.sva_info[index].get_sva_name::index`. A path ENDING in the select (`gp.m_extensions[ext]`, `info.addr[i]`)
keeps the bit_select parent: a first draft without that fence moved MiniAmiq/SeqDriver/UVM records AWAY (uvm_reg_map
767, uvm_tlm2_generic_payload 488) on a scratch run before any gate run and was refined (N/n05).

## Grid (`cases/`, 55 case dirs + the 4 pass-271 R cases measured as R0 before removal; both views; drivers/grid.sh,
every line carries rc: `evidence/grid.txt` 1062 lines, `evidence/grid_summary.txt`)

118 case-views (59 dirs incl. the R0 copies of r11u271repro/cases/R, removed afterwards to keep no duplicate
source; they are measured again in the controls): **92 moving, 61 entering STRICT_EQUAL, 0 leaving, 0 uhdm-cmp line
count changes, 0 nonzero exit codes, R11U270_OFF == pristine on 118/118, every mover returned to pristine bytes by
exactly ONE switch** (INSIDEPA 38, ENUMALIAS 16, TIMEKWSPAN 14, MARGIDXPARENT 14, SCOPEDEND 10).

| cases | law | shapes | result |
|---|---|---|---|
| I/i01, i05, i06, i07, i11, i13, i16, i17, i18, i21, i22 | § insideSetParamFoldKeepsPa270 | wildcard / named import in module function, class method, open-range set, mixed literal, interface function, macro body (the UVM shape), operation member, typed params, task, class-in-package with module import | fullname -> STRICT_EQUAL, both views |
| I/i23 | the same + case-inside | program function, nested inside, case-inside items in a class method | elab view -> STRICT_EQUAL; default view stage 1 on both (a program function io_decl face, not this ground's) |
| I/i02, i15 | the same | always_comb, generate always (bytes move, already equal) | STRICT_EQUAL both |
| I/i03, i04, i09, i10, i12, i19, i20, i24 | CONTROLS | local params (ref_obj), qualified `up::X`, module case-inside, header params, class params, enum members, `==`, a parameter as the LEFT operand | no verdict change |
| I/i08, i14, i25 | | elaborated cont_assign Rhs (ModuleEmit, sister), own-package param in a package function (golden folds, ours keeps ref_obj: stage 1), qualified member in an interface (stage 1 on both, a decompile/value face) | stage 1 unchanged, heads identical |
| E/e01, e02, e03, e05, e06 | § enumAliasCastBindsImportCopy270 | interface, module, class only, two interfaces, cast without a variable | depth -> STRICT_EQUAL |
| E/e04, e07, e08, e09, e10 | CONTROLS / residue | module var + cast, interface function, alias of alias, qualified cast, no up import | unchanged (e08, e09, e10 stage 1 on both, heads identical) |
| T/t02-t05 | § sysCallTimeKwNameSpan270 | function local init, class method, macro argument, `$time ()`, statement forms | endcol -> STRICT_EQUAL |
| T/t01, t06, t07 | | `realtime` variable (time vs real typespec), cont_assign `$time()` ref_typespec | stage 1 on both, heads identical |
| S/s02-s05 | § scopedCallPrefixEndsAtColons270 | `X::type_id::\n create`, static call, static property and localparam read, parameterized class | endline / endcol -> STRICT_EQUAL |
| S/s01 | | an interface typedef listing of `type_id` | stage 1 on both |
| N/n02, n04, n05, n06, n07 | § methArgPathIdxAtHierPath270 | class receiver, every arg position, a path ending in the select (fence), `this.`, extern method, task, module function and initial for-loop | fullname -> STRICT_EQUAL |
| N/n01, n03 | | an instantiated interface (stage 1 on both), a virtual interface (fullname -> endcol: the class_typespec `info sva_info[$]` endcol face) | |
| C/c01 | (sister decode) | constructor return class_var with `input` formals | unchanged, residue 1 |

## Census, sweeps and gates (frozen law binary 52efc588)

- Firing census (drivers/tracecensus.sh, run BEFORE the law sweep, filter built from `$FENCED`):
  `evidence/predict.txt` (md5 in `evidence/predict.md5`), 6 lines: surelog MiniAmiq d/t, SeqDriver d/t; probe
  r10uvm99repro/g99_a9_fence and r10earl41repro/v41v_comment (SCOPEDEND firing in the helper without byte effect);
  no uhdm2rtlil database.
- Pristine sweep (tests/sweep.sh probe+surelog+uhdm2rtlil): regressions=0 conversions=0 changes=0 in all three
  (the baseline exactly). Law sweep: probe regressions=0 conversions=0 **changes=1**; surelog regressions=0
  **conversions=2 changes=2**; uhdm2rtlil regressions=0 conversions=0 changes=0 (`evidence/sweep_gates.txt`). Both
  sweeps exit 1 on the law-index staleness check alone (tests/LAWS.md is regenerated last, in the patch).
  - Probe change: r10uvm99repro/g99_a9_fence `differ:fullname(2) -> differ:count(0)`: its two records (the `QA`
    member of `vv inside {QA, p1, p2}`, ref_typespec `work@xi99.c3` vs golden `work@xi99`) cleared; the remaining
    difference is the object count 342 vs 343 that pristine already has (the grown-count rule; away 0).
  - Surelog: the SeqDriver conversions and the MiniAmiq change above; LowMemLib/LowMemPkg testflags differ only by
    the workdir path in their detail text (environment).
- byteverify (fence-filtered hard-link mirrors, drivers/bvmirror.sh, SELFCHECK=1): 2560 databases,
  PATH_SETS_IDENTICAL, **MOVERS 4 / 2560** (MiniAmiq d/t, SeqDriver d/t, exactly the predicted), SELFCHECK 2559 / 2560
  flagged (every file compared against one fixed file: the fixed file itself is the one not flagged, an artefact of
  the self-check, not a mover). Probe: 1 of 4087 databases moving (g99_a9_fence; predicted; v41v_comment predicted
  but byte-identical, see the law). Downstream: 0 of 805 slang databases moving.
- uhdm-cmp on every touched row: 0 lines (all four are CMP_EQUAL / STRICT_NOTEQUAL rows, stage 1 equal).
- Canaries: surelog ok=50 changed=2 (the two SeqDriver conversions), uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both.
- Binary-path audit: 3273 of 3323 cmds.txt name the law binary, the other 50 carry no slang line (pristine sweep:
  3273 name the pristine binary).
- Downstream (tests/sweep.sh --corpus downstream, law then pristine, one at a time): 803 IDENTICAL / 66 SLANG_REJECT /
  2 EQUIVALENT / 0 DIVERGENT on both binaries, csvs identical.
- Away-moved census: dump census (drivers/awaycorp.sh) MiniAmiq d/t distance 104 -> 61 lost 0, SeqDriver d/t 76 -> 70
  lost 0; chain-keyed (drivers/awaychain.py with strictcmp_x) away=0 on all four corpus movers (toward 53 / 6) and on
  g99_a9_fence (toward 2).
- Determinism (drivers/det.sh, three concurrent draws of Earlgrey_0_1 and the UVM rows + Rggen, both modes): one hash
  per row-mode in 3 of 3, equal to the sweep's hash (4 of 4; `evidence/determinism.txt`).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 26 earlier repro dirs (r11u118repro,
  r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro,
  r11u271repro, v11u271repro, r11u268repro, v11u268repro, r11u266repro, v11u266repro, r11u169repro, r11u201repro,
  v11u201repro, r11u175uvm, r11u198repro, v11u198repro, r11u246repro, r11u12repro, r11u224repro, r11u264repro,
  v11u264repro): 4040 case-views, **6 moving, all entering STRICT_EQUAL** (r11u271repro R/r01, r02, r04 in both
  views), 0 leaving, 0 exit code changes, 0 uhdm-cmp line count changes (`evidence/controls.txt`). Before the
  refinement the same controls moved v11u271repro VN/vn19 (stage 1 on both, the qualified `pk::PQ` constant's parent
  moving away from golden's operation): that is what § insideSetQualKeepsOp270 fixed; every number above is from the
  final binary.

## Residues, ranked

1. **Sister ground, the last MiniAmiq face**: TaskFuncEmit's constructor return class_var span (above; C/c01). It is
   the ONLY record left on MiniAmiq d/t.
2. Inside-set neighbours: an own-package parameter read in that package's function (`I/i14`: golden folds to a
   constant at the package's param_assign, ours keeps `ref_obj`, stage 1); the elaborated cont_assign's inside Rhs
   (`I/i08`, ModuleEmit emitContAssigns, the sister's elaborated cont_assign face); a qualified member's fold encoding
   (`I/i25`, golden `INT:6` unparented vs ours `4'd6` DEC: ExprEmit, not attempted).
3. `$time` / `$realtime` typing: a `realtime` variable gets golden `time_typespec` where ours writes `real_typespec`
   (T/t01, t07: the variable declaration's typespec, TypeEmit), the cont_assign `$time()` ref_typespec (T/t06).
4. Enum alias: alias of alias (E/e08), qualified cast `up::sev_t'(x)` (E/e09), an interface that imports only the
   class package (E/e10): stage 1 on both, not decoded.
5. Method-argument naming: the interface-instance listing face of N/n01, the class_typespec `info sva_info[$]` endcol
   in an interface (N/n03).
6. The brief's items (1) "THEN THE PROBE RESIDUE" refresh and items (2) to (7) (pass 268's, 266's, 264's, 262's, 260's,
   258's and older residues, the probe residue by writer): NOT attempted in this pass.

## Process notes

- Two earlier law binaries were measured before the final one: on the first (14caa486) a census was started and
  stopped (own background task, no other process signalled) when fresh case I/i23 showed the case-inside items
  needed the law too; on the second (ba05bcad) the census, law sweep, grid and controls ran and the controls found
  v11u271repro VN/vn19 moving away (fixed by § insideSetQualKeepsOp270). The earlier workdirs were deleted and every
  number above was rerun on the final binary 52efc588.
- No fenced test was dispatched or read outside the gate sweeps; every corpus path list was filtered by `$FENCED`
  before any file was opened; byteverify ran on fence-filtered mirrors.
- The MiniAmiq / SeqDriver sources (UVM, svaunit) were read to decode the faces; they are not fenced.
