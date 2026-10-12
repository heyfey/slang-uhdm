# v11u298 — adversarial verification of r11u298 (pass 298, expression/parameter ground)

Base 458cb4cb (pass 296). Implementer's patch /tmp/r11u298.patch (md5 43aa492d), applied clean on a fresh
458cb4cb. Production surface of this verification: src/ExprEmit.cpp and src/R298.h only (two refinements of the
implementer's laws behind their own switches).

## Verdict

**VERIFIED WITH TWO PRODUCTION REFINEMENTS.**

- Every headline number of the implementer reproduces bit for bit (below).
- The fresh attack found **one break on legal SystemVerilog where pristine was right**:
  § nestedCastOuterTpPlaceholder298 wrote the `unsupported_typespec` placeholder for a cast written as a
  **port actual** or a **gate terminal** inside the nested module.
  - VN/vn06 and VN/vn16 go from STRICT_EQUAL (pristine) to `type` (law), chain away 4 on each view.
  - VN/vn15 and VN/vn21 read `type` with chain away 4, and VN/vn19 reads chain away 1.
  - Fixed by § nestedCastPlaceholderCaOnly298v.
- It also found one shape where § castClsTpOwnDefaultObj298 moved a pristine-wrong cell further from golden:
  a cast in a class **nested** inside the type parameter's class.
  - VP/vp13: uhdm-cmp goes from 14 to 58 lines. Pristine had golden's location; the law lost it.
  - Fixed, and converted, by § castClsTpNestedClsPlaceholder298v.
- Neither refinement fires anywhere in the gate. The fix sweep is row-identical to the law sweep, and 0 databases
  move between the law and the fix (corpus 2560, probe 4087, downstream 805).

## The refinements (src/ExprEmit.cpp, switches in src/R298.h, read through r11v298On)

`R11V298_OFF` drops both and gives the implementer's law bytes: 92 of 92 fresh case-views and 136 of 136 of the
implementer's grid. `R11U298_OFF` still gives pristine's bytes on the fix binary: 92 of 92 and 136 of 136.
`R11U298_TRACE` logs each refinement's firing and abstention.

1. **§ nestedCastPlaceholderCaOnly298v** — switch `R11V298_CASITE_OFF`. This refines § nestedCastOuterTpPlaceholder298.
   - **The rule:** the placeholder is Surelog's writeCont_assign face. Only a cast inside a **continuous assignment**
     or a **net declaration assignment** of the nested module takes it.
   - **Where it now stands aside:** a cast in a port actual (named or positional) or in a gate-primitive terminal.
     Golden keeps the outer default `logic_typespec` there, as pristine does.
   - **The distinguisher:** the cast's syntax ancestors, up to its nearest module declaration, include no
     ContinuousAssign or NetDeclaration node.
   - **Contexts the law never reached in the first place:** processes, functions, variable initializers and
     parameter overrides (vn13, vn14, vn20, and the implementer's nc06 and nc12).
2. **§ castClsTpNestedClsPlaceholder298v** — switch `R11V298_NESTCLS_OFF`; `R11U298_CLSTPOBJ_OFF` and
   `R11U298_CLSTPOOB_OFF` also drop it. This refines § castClsTpOwnDefaultObj298 and extends
   § castClsTpOutOfBodyPlaceholder298.
   - **The shape:** a cast to a class's type parameter, written in a method of a **different** class declaration.
     That is either a class nested in the parameter's class (`class gen #(type U = ...); class inner; ... U'(3)`)
     or a derived class casting to the base class's parameter by name (`class der extends base #(...); ... U'(3)`).
   - **What golden writes:** Surelog's unresolved placeholder, an `unsupported_typespec` named after the written
     name at the cast token, for every default kind, `int` included.
     - Golden VP/vp13 (`logic [7:0]` default) and VP/vp16 (`type T = int`) read `unsupported_typespec (U)` and
       `(T)` at 7:30-31.
     - VP/vp03 (derived) reads the same.
   - **The distinguisher:** syntactic. The nearest enclosing ClassDeclaration of the cast is not the type parameter's
     class declaration.
     - An out-of-block body (`function void gen::f()`, a scoped name) is read as the parameter's own class.
     - So VP/vp01, where a nested class's extern method is defined inside the outer class's body, keeps
       § castClsTpOwnDefaultObj298's default object. Golden binds that object there (5:26-37).

## Reproduction of the implementer's numbers (evidence/gates.txt)

I built both binaries myself and froze them in /tmp/v11u298_bin before any measurement.

- **Builds:** pristine f084a2ac (the base's md5 in the brief), law 40dd231d (equal to the implementer's), fix 008114c7.
- **Pristine sweep:** probe 3971 + 116; surelog 480 + 0 and 474 + 0; uhdm2rtlil 803/1/67 in both modes;
  downstream 803/66/2/0. The downstream csv is byte-identical to the committed one, and regressions are 0 in every stage.
- **Law sweep:**
  - Probe 3972 + 115: regressions 0, conversions 1 (`r10earl31repro/v4_ops,EQUAL,,equal`, from differ:endcol(4)),
    changes 0.
  - Both corpora: regressions 0, conversions 0, changes 0.
  - Downstream 803/66/2/0, with the csv byte-identical to the committed one.
  - Row by row against pristine: the only difference is the v4_ops probe row, besides the two LowMem detail-text lines.
- **Fix sweep:** row-identical to the law sweep in all four csvs (besides the LowMem detail text).
- **byteverify** (r11v75repro/byteverify.sh on fence-filtered mirrors, 8 fenced paths skipped by name in each):
  - 0 of 2560 corpus databases move for law vs pristine, fix vs law and fix vs pristine.
  - Probe: 1 of 4087 for law vs pristine and for fix vs pristine (v4_ops); 0 of 4087 for fix vs law.
  - Downstream slang lane: 0 of 805 in each comparison.
  - The probe comparison needs equal source paths, so the pristine probe stage was rerun from the law worktree
    (/tmp/v11u298_prP).
  - **SELFCHECK 2559 of 2560:** the self-check compares every patched file against ONE fixed pristine file, the first
    path. That path's own patched file is byte-identical to it when it is not a mover, so 2559 is the expected
    reading by construction. It is not a movers line.
- **Firing census:**
  - Rerun on the frozen law binary, it is byte-identical to the implementer's predict.txt: 6 lines.
    - The only firing database is v4_ops (pkgQualBoundSpanTernary298 x2).
    - The other lines are abstentions: v3_tern, and BlackBePipeInt and Earlgrey_0_1 in both modes.
  - On the fix binary, frozen before the fix sweep, it is byte-identical to the law census. No refinement tag fires
    in the gate.
  - **Positive control:** the refinement tags print on their witnesses (vn06, vn19, vp13, vp03).
- **Canaries** on the law and fix sweep csvs: surelog ok=52, uhdm2rtlil ok=16, both ctcan2 checks PASS.
- **Binary-path audit:** each of the three sweeps reads own=3265, other=0, noslang=50, fenced_skipped=8.
- **Determinism:** three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
  BuildUVMPkg and Rggen, for law and for fix.
  - Each row-mode gives one hash, equal to its sweep's database and to the implementer's evidence/determinism.txt.
  - Scoreboard/testflags and Rggen/testflags write no database, as at the base.
- **The implementer's grid rerun** (136 case-views, evidence/impl_grid_rerun*.txt):
  - Every verdict field matches on 952 of 952 lines. md5 differs only by the worktree path in the database.
  - 110 movers, 87 entering STRICT_EQUAL, 0 leaving.
  - R11U298_OFF equals pristine on 136 of 136.
  - The fix equals the law on 136 of 136.
- **The implementer's byte controls rerun** (19 repro dirs, 1282 case dirs, 2564 case-views; evidence/controls19*):
  - 8 movers, 4 entering STRICT_EQUAL (vm13_nested d/e and vc06_tp_nested_cls d/e), 0 leaving, 0 exit-code changes.
  - Chain away 0 on all 8, with 1, 9, 4 and 1 records toward golden on vm13, vc06, ct05 and vc03.
  - The fix equals the law on all 2564.

## Widened byte controls (evidence/controls_trigger*)

**Scope:** 227 case dirs from 70 earlier repro dirs, 454 case-views, selected by the laws' triggers. The path list was
filtered by $FENCED before any file was opened. The triggers:
- a nested module: 102 dirs;
- a `::` and a `?` inside one bracket: 2 dirs;
- a class type parameter beside a written cast: 68 dirs;
- an out-of-block method beside a cast: 55 dirs.

**Result:**
- **v11u192repro Q/qk03_cast_cond d/e:** 2 movers, both entering STRICT_EQUAL under § pkgQualBoundSpanTernary298.
  Chain away 0, with 4 and 2 records toward golden.
- 0 leaving STRICT_EQUAL and 0 exit-code changes.
- The fix equals the law on all 454.

## Attack grid (cases/VN, VQ, VP: 46 case dirs, 92 case-views; evidence/grid.txt, grid_summary.txt, grid_away.txt)

Each line carries the exit code. The labels are pristine, law, law+R11U298_OFF, law plus each of the four law
switches, fix, fix+R11V298_OFF, fix+R11U298_OFF, and fix plus each refinement switch.

**Law vs pristine:**
- 72 movers, 34 entering STRICT_EQUAL and **4 leaving it** (vn06 d/e, vn16 d/e).
- Chain away appears on 10 case-views: 4 each on vn06, vn15, vn16 and vn21, and 1 on vn19.

**Fix vs pristine:**
- 68 movers, 44 entering STRICT_EQUAL, 0 leaving, 0 exit-code changes.
- Chain away 0 on every mover.
- R11U298_OFF on the fix equals pristine on 92 of 92, and R11V298_OFF on the fix equals the law on 92 of 92.

**Fix vs law** (16 case-views, each restored to the law's bytes by exactly one refinement switch):
- CASITE: vn06, vn15, vn16, vn19 and vn21, in both views.
- NESTCLS: vp03, vp13 and vp16, in both views.

**Downstream** (scripts/downstream_uhdm2rtlil.py one(), evidence/downstream_cases.txt):
- 45 of the 46 case dirs read IDENTICAL on all three binaries.
- VQ/vq09_pkg_func reads DIVERGENT on all three binaries (pristine included).
- No verdict changes.

| case | law | shape | default view P -> L -> F | elaborated view P -> L -> F |
|---|---|---|---|---|
| VN/vn01_gen_before_plain | § nestedCastOuterTpPlaceholder298 | an if-generate instance written before a plain instance | stage1 17 -> 17 -> 17 (toward 1) | stage1 62 -> 340 -> 340 (toward 1; the walk now heads at golden's generate instance work@top.g::inner, which golden lists without its cont_assign) |
| VN/vn02_nda | § nestedCastOuterTpPlaceholder298 | the cast in a net declaration assignment | stage1 62 -> EQ -> EQ | stage1 62 -> EQ -> EQ |
| VN/vn03_operand | § nestedCastOuterTpPlaceholder298 | the cast as an addition operand and inside a concatenation | stage1 -> EQ -> EQ | stage1 -> EQ -> EQ |
| VN/vn04_two_nested | § nestedCastOuterTpPlaceholder298 | two nested modules each casting | stage1 -> EQ -> EQ | stage1 -> EQ -> EQ |
| VN/vn06_portconn | § nestedCastPlaceholderCaOnly298v | **a named port actual cast in the nested module** | **EQ -> type (away 4) -> EQ** | **EQ -> type (away 4) -> EQ** |
| VN/vn07_rev_order | § nestedCastOuterTpPlaceholder298 | two instances in reverse name order, the outer overridden from a wrapper | stage1 -> EQ -> EQ | stage1 -> EQ -> EQ |
| VN/vn08_ternary_branch | § nestedCastOuterTpPlaceholder298 | the cast as a ternary branch and under a unary | stage1 -> EQ -> EQ | stage1 -> EQ -> EQ |
| VN/vn09_outer_also | § nestedCastOuterTpPlaceholder298 | the outer module casts to T as well | stage1 -> EQ -> EQ | stage1 -> EQ -> EQ |
| VN/vn10_outer_body_tp | § nestedCastOuterTpPlaceholder298 | the outer type parameter declared in the module body | rc4 stage1 22 -> rc4 type -> rc4 type | the same |
| VN/vn11_nested_two_levels | § nestedCastOuterTpPlaceholder298 | two levels of nesting | stage1 257 unmoved | stage1 261 unmoved |
| VN/vn12_outer_signed_int | § nestedCastOuterTpPlaceholder298 | a shortint default | stage1 24 -> EQ -> EQ | stage1 24 -> EQ -> EQ |
| VN/vn13_var_init | § nestedCastOuterTpPlaceholder298 | a variable initializer (law does not fire) | stage1 43, bytes unmoved | the same |
| VN/vn14_initial_ff | § nestedCastOuterTpPlaceholder298 | always_ff and initial (law does not fire) | EQ unmoved | EQ unmoved |
| VN/vn15_portconn_and_assign | § nestedCastPlaceholderCaOnly298v | a port actual cast before an assign cast | stage1 -> type (away 4) -> EQ | stage1 -> type (away 4) -> EQ |
| VN/vn16_portconn_outer | § nestedCastPlaceholderCaOnly298v | **port actual casts in the outer and in the nested module** | **EQ -> type (away 4) -> EQ** | **EQ -> type (away 4) -> EQ** |
| VN/vn17_gen_only | § nestedCastOuterTpPlaceholder298 | the nested module instantiated only in an if-generate | stage1 58 (bytes move, away 0) | the same |
| VN/vn18_plain_before_gen | § nestedCastOuterTpPlaceholder298 | a plain instance written before an if-generate instance | stage1 62 -> 324 -> 324 (toward 1, the walk now heads at the generate instance) | 62 -> 340 -> 340 (toward 1) |
| VN/vn19_gate_term | § nestedCastPlaceholderCaOnly298v | a gate-primitive terminal cast | fullname -> fullname (away 1) -> fullname (pristine bytes) | the same |
| VN/vn20_param_ovr | § nestedCastOuterTpPlaceholder298 | a cast in a parameter override (law does not fire) | stage1 74 unmoved | the same |
| VN/vn21_portconn_positional | § nestedCastPlaceholderCaOnly298v | a positional port actual cast and an assign cast, two instances | stage1 -> type (away 4) -> EQ | stage1 -> type (away 4) -> EQ |
| VP/vp01_nested_cls_extern | § castClsTpOutOfBodyPlaceholder298 | a nested class's extern method defined in the outer class body | stage1 209 -> 209 -> 209 (flat toward 4; golden binds the default object, as the law does) | the same |
| VP/vp02_constraint | § castClsTpOwnDefaultObj298 | a constraint and a property initializer (law does not fire) | stage1 43 unmoved | the same |
| VP/vp03_derived_inherit | § castClsTpNestedClsPlaceholder298v | a derived class casting to the base's U | stage1 14 -> 14 (law = pristine) -> EQ | the same |
| VP/vp04_extern_ctor | § castClsTpOutOfBodyPlaceholder298 | an extern constructor and an extern task | stage1 22 -> EQ -> EQ | the same |
| VP/vp05_module_extern | § castClsTpOutOfBodyPlaceholder298 | a module class with an extern method | rc4 stage1 unmoved | the same |
| VP/vp06_value_param_range | § castClsTpOwnDefaultObj298 | a default ranged by a class value parameter, specialized | line -> EQ -> EQ | the same |
| VP/vp07_static_this | § castClsTpOwnDefaultObj298 | a this. path and a static call cast, two type parameters | stage1 51 (toward 8) | the same |
| VP/vp08_unit_class | § castClsTpOwnDefaultObj298 | a $unit class with an extern method | rc4 stage1 unmoved | the same |
| VP/vp09_struct_enum_default | § castClsTpOwnDefaultObj298 | struct and enum defaults (abstains) | fullname unmoved | the same |
| VP/vp10_extern_in_interface_class_user | § castClsTpOutOfBodyPlaceholder298 | an extern function returning U with a cast in a begin block | stage1 22 (toward 4) | the same |
| VP/vp11_module_class_used | § castClsTpOwnDefaultObj298 | a module class used by an initial block | rc4 type unmoved | the same |
| VP/vp12_unpacked_default | § castClsTpOwnDefaultObj298 | reg vector and bit defaults | line -> EQ -> EQ | the same |
| VP/vp13_inner_class_outer_tp | § castClsTpNestedClsPlaceholder298v | **a nested class casting to the enclosing class's vector U** | **stage1 14 -> stage1 58 -> EQ** | **the same** |
| VP/vp14_two_classes_same_name | § castClsTpOwnDefaultObj298 | two classes with a U each | line -> EQ -> EQ | the same |
| VP/vp15_extern_spec_used | § castClsTpOutOfBodyPlaceholder298 | an extern method with the class specialized and called | stage1 22 -> EQ -> EQ | the same |
| VP/vp16_inner_class_int_tp | § castClsTpNestedClsPlaceholder298v | a nested class casting to the enclosing class's int T, and its own V | stage1 16 -> 16 (toward 4) -> EQ | the same |
| VQ/vq01_cmp_cond | § pkgQualBoundSpanTernary298 | a comparison condition and operation branches | endcol -> EQ -> EQ | the same |
| VQ/vq02_both_bounds | § pkgQualBoundSpanTernary298 | ternaries on both bounds | endcol -> EQ -> EQ | the same |
| VQ/vq03_genif | § pkgQualBoundSpanTernary298 | an if-generate assign and a case-generate process | stage1 48 (toward 6/2) | the same |
| VQ/vq04_genfor_two | § pkgQualBoundSpanTernary298 | two-level for-generate with a genvar condition | endcol -> fullname (toward 4) | EQ -> EQ (bytes move with identical dumps; strict and no-canon walks equal) |
| VQ/vq05_case_item | § pkgQualBoundSpanTernary298 | a case expression, an if condition and a for bound | endcol -> EQ -> EQ | the same |
| VQ/vq06_depth3 | § pkgQualBoundSpanTernary298 | instance depth 3 with a parameter condition | endcol -> EQ -> EQ | the same |
| VQ/vq07_incdec_stream | § pkgQualBoundSpanTernary298 | an increment operand and a streaming target | endcol -> fullname (toward 8/4) | the same |
| VQ/vq08_call_arg | § pkgQualBoundSpanTernary298 | a user-call argument and a system-call argument | stage1 17 (toward 8/4) | the same |
| VQ/vq09_pkg_func | § pkgQualBoundSpanTernary298 | a package function's return in another package | stage1 36 unmoved; downstream DIVERGENT on every binary | the same |
| VQ/vq10_nested_paren | § pkgQualBoundSpanTernary298 | the ternary inside an operation with a cast branch | endcol -> EQ -> EQ | the same |

(VN/vn05, a nested interface, was dropped: Surelog reports 3 syntax errors and writes no golden.)

## The laws as landed (unchanged by this verification except through the two new switches)

- § nestedCastOuterTpPlaceholder298 `R11U298_NESTCASTTP_OFF`
- § pkgQualBoundSpanTernary298 `R11U298_QBTERN_OFF`
- § castClsTpOwnDefaultObj298 `R11U298_CLSTPOBJ_OFF`
- § castClsTpOutOfBodyPlaceholder298 `R11U298_CLSTPOOB_OFF`

The implementer's statements in tools/probe/r11u298repro/README.md hold, with these corrections:
- Law 1 reaches only continuous and net declaration assignments.
- Law 3's default-object binding stands aside for a cast written in another class declaration, which takes the
  placeholder.

## Residues, ranked (all wrong on pristine too)

1. **Generate-scope nested instances** (vn01, vn17, vn18, and the implementer's nc18).
   - Golden lists `work@top.g::inner` without its cont_assign.
   - Our writer is ModuleEmit's nested-instance emission (the sister's ground). Report only.
2. **Two-level nesting and the non-firing contexts** (vn11, vn13, vn20): stage 1 on every binary, the head elsewhere.
3. **The outer body type parameter** (vn10, exit 4 on every binary): the law moves it from stage 1 to type.
4. **vq09:** a ternary bound inside a package function called from another package.
   - Stage 1 and downstream DIVERGENT on every binary.
   - This is the implementer's residue 1, the package-function return fold in the elaborated listing.
5. **The stage-1 movers toward golden** (vq03, vq08, vp07, vp10) and **the endcol -> fullname changes** (vq04 d, vq07),
   each with away 0.
6. **The class shapes the laws do not move:**
   - vp02: constraint and property initializer.
   - vp05 and vp11: module classes (exit 4).
   - vp08: a $unit class (exit 4).
   - vp09: struct and enum defaults.
   - vp01: its head is outside the cast.
7. The implementer's ranked residues 1 to 5 stand as written.

## Process

- **The fence:** every driver reads $FENCED fail-closed from tools/probe/r11u107repro/canaudit.sh (drivers/env.sh).
  - Every corpus path list was filtered before any file was opened (mirror.sh, audit.sh, bytepd.sh, controls3.sh and
    the trigger scan over tools/probe).
  - The census and determinism runs used the harness's own --filter.
  - No fenced name is spelled here.
- **Processes and writes:** no gdb was run, no other agent's process was listed or signalled, and nothing was written
  to the main tree.
- **THE VERIFIER'S SLIP, no effect on any number:**
  - The firing census on the law binary ran concurrently with the law sweep, not before it. It is a reproduction of the
    implementer's frozen prediction, and its output is byte-identical to it.
  - The fix census was frozen before the fix sweep.
- **The law index:** every sweep exited 1 on the law-index check alone. tests/LAWS.md was regenerated last.

## Files

- **drivers/:**
  - Copied from r11u298repro: env.sh, case.sh, awaychain.py, awayrows.py, away.py, strictcmp_x.cpp, cc_x.sh,
    dscases.py, det.sh, audit.sh, mirror.sh, tracecensus.sh.
  - New: grid3.sh, controls3.sh, away1.sh, bytepd.sh, gridcmp.py, ctlsum3.py.
- **evidence/:** gates.txt, grid.txt, grid_summary.txt, grid_away.txt, impl_grid_rerun.txt,
  impl_grid_rerun_summary.txt, controls19.{lst,txt}, controls19_summary.txt, controls_trigger.{lst,txt},
  controls_trigger_summary.txt, downstream_cases.txt, determinism.txt, predict_law.txt, predict_fix.txt, and
  sweep_{P,L,F}.log.
