# v11u271 — adversarial verification of r11u271

Base commit `9cb6fddb` (pass 269). The implementer's patch (`/tmp/r11u271.patch`, md5 `1ab13819`) applied clean on a
fresh worktree; this pass rebuilt pristine and law, reproduced every headline number, attacked the three laws with
56 fresh case dirs, found **two breaks** (pristine right, the law wrong, on legal SV) and fixed both behind their own
switches in ModuleEmit and TypeEmit (the module/type ground). Nothing under `results/`, `tests/` (apart from the
regenerated `tests/LAWS.md`) or `third_party/` is touched; no file of the sister's ground is edited.

| binary | md5 | what |
|---|---|---|
| pristine | `6712ed7d618895d7c33dcfd915d13981` | the base, byte-identical to the main tree's `build/slang-uhdm` |
| law | `ae0f712864424d1c4301f8eb5e8f1df7` | the implementer's patch, the implementer's md5 |
| fix | `4f7e483f710be10515b545221c046711` | law + the two refinements below |

All three link slang 12.0.0+545f88b2e. Every binary was frozen (`chmod 555`) before it was measured.

## Verdict

The implementer's laws hold on every gate database: the reproduction is bit for bit. Two fresh shapes break them,
neither visible to any gate database:

1. **A bound instance (`bind dut chk u_chk (...)`)** with `wire [31:0] w = pk::PQ;`: VN/vn28 is judge-equal on
   pristine (`STRICT_NOTEQUAL fullname`) and uhdm-cmp stage 1 under the law. § ndaConstRhsFreshLhs271 clones the
   cell, but in a bound instance's default view the listed net's ref_typespec is still unbound when
   `emitContAssigns` runs, so the fresh Lhs got **no typespec**. Golden's `clone_tree` keeps the declared one.
2. **A class declared in a module or program body** with a specialization typedef. On VT/vt08 the law moves 3
   chain-keyed records away from golden in the default view and 8 in the elaborated view; on VT/vt26 the counts
   are 6 and 8. Both cases are stage 1 on every binary. Golden lists the specialization (`typedef reg_c #(sbase)
   type_id;`) as a bare class_typespec, while ours lists its param_assigns; that listing is pass 269's residue
   VU/vu04, wrong on pristine too. Our listing therefore marks the type parameter's own class_typespec visited
   first. Once § tpUseSharesOwnTs271 shares that object, the strict walk drops golden's later `class_typespec comp`
   records under the property, the local and the return.

With the fix, every gate stays where the law put it, and the fix moves no gate database:

- 0 of 2560 corpus, 0 of 4087 probe and 0 of 805 downstream slang-lane databases move against the law.
- The firing census, frozen before the fix sweep, predicted exactly that.
- On the fresh cases, the fix gives 0 case-views leaving STRICT_EQUAL, 0 losing uhdm-cmp and 0 chain-keyed records
  away from golden.

**Deliverable**: `/tmp/r11u271.verified.patch`, which is the implementer's patch plus the two refinements and this
directory.

## Rows (this pass's own sweeps; pristine = the committed baselines exactly)

| row-mode | pristine | law = fix |
|---|---|---|
| SeqDriver default | `differ:depth(1)` #218195 (`class_var create_component` vs our `class_typespec uvm_component` copy) | `differ:fullname(6)`: #255036 / #255039 / #255042 / #258671 / #258674 / #258677, all `ref_typespec` full names `adpcm_pkg::adpcm_seq_item` (golden) vs `...::__m_uvm_field_automation` (ours), the sister's `inside`-set face |
| SeqDriver testflags | `differ:depth(1)` #218207 | `differ:fullname(6)` |
| MiniAmiq default | `differ:endcol(2)` #217949 (sister) + #223178 | `differ:endcol(5)`: #217949 unchanged (`$sformatf` 434:75 vs 434:85), #227043 / #227046 / #227049 (the `inside` face), #227149 the walk divergence (`enum_typespec uvm_pkg::uvm_severity` vs our `ref_typespec <in>uvm_pkg::uvm_severity_type`), objects 435559 vs 435549 |
| MiniAmiq testflags | `differ:endcol(2)` | `differ:endcol(5)` |

No corpus row converts. Earlgrey_0_1 d/t, Rggen d, BlackBePipeInt d/t, BuildUVMPkg d/t, SimpleUVM d/t and
Scoreboard d stay CMP_EQUAL.

## The implementer's laws (reproduced) and the verifier's refinements

The implementer's laws are unchanged:

- § tpUseSharesOwnTs271, switches `R11U271_TPUSESHARE_OFF` and `R11U271_TPFORMALSHARE_OFF`.
- § ndaConstRhsFreshLhs271, switch `R11U271_NDACONSTLHS_OFF`.
- § ndaImpEnumConstUnlocated271, switch `R11U271_NDAIMPENUM_OFF`.
- `R11U271_OFF` turns off every law and every refinement (the pristine bytes).

The refinements live in `src/R271.h` as `r11v271On`. Each reads its own `R11V271_<FIX>_OFF`, and `R11V271_OFF` drops
both (the law's bytes).

### § ndaLawLhsTsDeferred271v (ModuleEmit `emitContAssigns`) — switch `R11V271_LAWLHSTS_OFF`

**Scope.** The rule covers a cell that § ndaConstRhsFreshLhs271 alone clones. It does not cover the literal,
operation or substituted-parameter rule. In that cell the listed net's ref_typespec may still be unbound, as in a
bound instance in the default view, where the net typespecs come after the continuous assignments.

**The fix.** In that case the fresh Lhs queues its own typespec on `pendingNetDeclTs` (drained in `emitTopPorts`), as
the bound-listing branch does. Golden's `UhdmWriter::writeCont_assign` clones the whole cell (`clone_tree`), Lhs
typespec included.

**Results.**
- VN/vn28 default: law uhdm-cmp stage 1 -> fix `STRICT_NOTEQUAL depth`, judge-equal again. Its first record moves
  later than pristine's (#130 vs #112). The chain-keyed census against pristine reads 0 away and 8 toward.
- VN/vn20 default: stage 1 -> `STRICT_NOTEQUAL depth`, 0 away and 11 toward.
- VN/vn30: 0 away and 10 toward.

**Not fixed: the literal branch.** The same defect stands on the base's literal branch. VN/vn27 (`wire [31:0] w_l = 6;`
in a bound instance) is stage 1 on all three binaries, and it is left alone: it is pristine-wrong, and a general fix
would move the base's bytes.

**Draft 1, withdrawn before any gate run.** A design-final drain of leftover `pendingNetDeclTs` entries fired on
nothing: the entries were never left over, the listed net was simply unbound at clone time (`ts!=null, actual=null`,
seen in a debug build).

### § tpUseShareModClassAbstains271v (TypeEmit `classTpDefaultTsDrain180`, the three redirect branches) — switch `R11V271_MODCLASS_OFF`

**The rule.** The redirect stands aside for a type parameter whose class sits in an instance body (a module,
interface or program). Package and `$unit` classes keep the law; VT/vt24, a `$unit` class, enters STRICT_EQUAL in the
default view on the law and on the fix.

**Results.**
- VT/vt08 and VT/vt26 return to pristine's bytes, so chain away goes back to 0.
- VT/vt25 (a module class with no specialization typedef: the law neutral, 0 away and 0 toward) also returns to
  pristine.
- Byte controls r11u180repro A/a16 and r11u241repro TD/d08 return to pristine in both views (module classes, the law
  neutral there: 0 away and 0 toward).

**When to drop it.** The switch can go once our specialization listing for module-declared classes matches golden
(pass 269's residue VU/vu04).

## Reproduction of the implementer's numbers (all bit for bit)

**Builds.**
- The pristine md5 equals the main tree's build.
- The law md5 equals the implementer's.

**Grid** (the implementer's `cases/`, 49 dirs, 98 case-views, 686 lines with rc):
- Identical to the implementer's `evidence/grid.txt` in every field but the output md5. That md5 embeds the case path:
  `/tmp/wt_r11u271` vs `/tmp/wt_v11u271`.
- Summary: 76 moving, 63 entering, by-switch 52 / 14 / 4, attrib_0 = 6 (`evidence/grid_implementer_rerun.txt`).

**Sweeps** (`tests/sweep.sh --jobs 3`, workdirs `/tmp/v11u271_wd{P,L,F}`):

| stage | pristine | law | fix |
|---|---|---|---|
| probe | 3593 + 494, 0/0/0 | 3604 + 483: regressions 0, conversions 11, changes 2 | identical csv to law |
| surelog | 476 + 4 / 470 + 4, 0/0/0 | regressions 0, conversions 0, changes 4 (MiniAmiq d/t endcol(2) -> endcol(5), SeqDriver d/t depth(1) -> fullname(6)) | the same, csv identical to law apart from the LowMem detail text (workdir path) |
| uhdm2rtlil | 1606 + 0 | unchanged | identical csv |
| downstream | 803 / 66 / 2 / 0 | csv identical to pristine's | csv identical |

**Probe conversions and changes** (law = fix):
- Eleven conversions:
  - r11u88repro grid: a3_ndassign, q1_ifnda, q2_ndakinds, q7_ndamod.
  - r11v88repro grid: v1_pkgshadow, v20_ndahier, v25_enumshadowmod, v26_pkgvecshadow, v28_ndaimport,
    v2_enumshadow.
  - r11v96repro: v6_modhome96v.
  - All of them `depth(1) -> EQUAL`.
- Two changes:
  - g99_a2_proc `depth(1) -> count(0)`: objects 242 vs 243, the trailing `logic_net flg99`, chain 0 away and 3
    toward.
  - q12_ndaparamenc `endcol(2) -> endcol(1)`: chain 0 away and 78 toward.

**Byteverify against pristine** (fence-filtered hard-link mirrors, SELFCHECK=1):
- Corpus: 11 movers of 2560 (ArrayMethodIterator, BuildUVMPkg, MiniAmiq, SeqDriver and SimpleUVM in both modes,
  plus Scoreboard default), each with the implementer's hashes. Selfcheck: 2559 of 2560 flagged.
- Probe: 133 of 4087 move, exactly the implementer's 133 predicted names. Selfcheck: 4086 of 4087. The first probe
  compare is described under Process.
- Downstream slang lane: 0 of 805. Selfcheck: 804 of 805.

**Firing census.** Rerun with `drivers/tracecensus.sh` from r11u271repro, fence-filtered: 144 lines, identical to the
implementer's `predict.txt` line for line.

**Corpus movers.**
- uhdm-cmp: 0 lines on all 11.
- `R11U271_OFF`: pristine's bytes on 11 of 11.

**Away census, chain-keyed** (`awaychain.py`, `strictcmp_x` rebuilt from drivers/cc_x.sh): 0 away on all 11 corpus
movers, all 133 probe movers and all 254 control movers.

**Byte controls.**
- The 23 dirs rerun to 3258 case-views: 254 moving, 4 entering, 0 leaving, no rc or cmplines change. The mover lines
  are identical to the implementer's.
- Widened by 11 dirs (r11u112, r11u241, v11u241, r11u243, v11u243, r11u259, v11u259, r11u260, v11u260, r11u263,
  v11u263): 1060 case-views, 78 moving, 4 entering (r11u241 TD/d07 and v11u241 TP/t13 in both views), 0 leaving,
  chain 0 away on all 78.
- With the fix over all 34 dirs (4318 case-views): 328 moving, 8 entering, 0 leaving, rc and cmplines unchanged.
- Fix vs law over the 34 dirs: 4 case-views differ, A/a16 and TD/d08 in both views, both back to pristine as
  described under § tpUseShareModClassAbstains271v.
- The pristine rerun is byte-identical.

**Dump census on stage-1 movers.** Some movers lose dump lines (22 control case-views, plus VT vt05 / vt12 / vt17 /
vt23). Every lost line is the shared type-parameter typespec's `vpiParent`, plus uhdm-dump's expansion of that
parent. Golden parents the one object at a declaring `class_var` (vt12: `m`) or at the chain's last type_parameter
(r11u188 T/t18: `U`); ours parents it at the type_parameter `T`, and pristine matched only on its spurious second
object. Neither comparator reads that field, and the chain-keyed record census reads 0 away on every one of them
(residue 4).

**Gate checks on the law and fix sweeps.**
- Canaries: surelog ok=50 changed=2 (SeqDriver d/t), uhdm2rtlil ok=16.
- ctcan2: PASS on both.
- Binary audit: 3265 of 3315 fence-filtered cmds.txt name each sweep's own binary, and the other 50 carry no
  slang-uhdm invocation.

**Determinism.** Three concurrent draws per row-mode on Earlgrey_0_1, MiniAmiq, SeqDriver, SimpleUVM, Scoreboard,
BuildUVMPkg and Rggen, for both the law and the fix: one hash each, equal to the sweep's. BuildUVMPkg reads
`00b64027` in both modes.

**Downstream on cases.** The implementer's 49 dirs plus the fresh 56 run on pristine, law and fix: 104 IDENTICAL on
all three binaries, and VN/vn22 EQUIVALENT on all three, which is pre-existing. The implementer's README lists T/t10
and T/t16 as SLANG_REJECT; on the delivered case text both read IDENTICAL (NO_GATES) on both binaries.

## Fresh cases (`cases/`, 56 dirs, both views; `drivers/vgrid.sh`, every line with its exit code: `evidence/grid_fix.txt`)

Configurations:

- P, L and F.
- FV: F + `R11V271_OFF`. It equals L's bytes on 210 of 210 case-views.
- FOFF: F + `R11U271_OFF`. It equals P's bytes on 210 of 210.
- F with each of the six switches off.

Summary, from `evidence/grid_fix_summary.txt`; the implementer's 98 case-views are included:

- Fix vs pristine: 162 case-views move and 93 enter STRICT_EQUAL. None leaves, none loses uhdm-cmp and none changes
  rc. The chain-keyed census reads 0 away on all 162.
- Fix vs law: 12 move, 6 by `R11V271_LAWLHSTS_OFF` and 6 by `R11V271_MODCLASS_OFF`, each by exactly one switch. 2
  regain uhdm-cmp: vn20 and vn28 in the default view.

On the fresh 112 case-views alone:
- The law enters 30, leaves 0 and loses uhdm-cmp on 1 (vn28). Its chain census moves records away on vt08 (3 / 8),
  vt26 (6 / 8) and vn20 (8 away / 9 toward).
- The fix enters 30 and leaves 0, with 0 away.

| cases | law | shape | pristine -> fix |
|---|---|---|---|
| VN/vn10_mod_named_import_param, vn12_gen_mod_pkg_param, vn15_mod_two_files, vn23_crlf_import | § ndaConstRhsFreshLhs271 / § ndaImpEnumConstUnlocated271 | named import, instances in a for-generate with an override, the package in an included file, a CRLF file | stage 1 -> STRICT_EQUAL (both views) |
| VN/vn04_mod_pkg_param_delay, vn13_iface_param_override, vn14_mod_net_ref_control, vn29_bind_iface_pkg_param | § ndaConstRhsFreshLhs271 | a constant delay, interface parameters with an override, a net-reference neighbour, a BOUND interface | depth -> STRICT_EQUAL |
| VN/vn21_iface_modport_port | § ndaConstRhsFreshLhs271 | interface nets read through a modport port, named and positional | depth -> fullname (0 away, 26 toward; the 8 records pre-exist behind pristine's divergence: residue 5) |
| VN/vn20_bind_mod_pkg_param, vn28_bind_pkg_param_only, vn30_bind_two_targets | § ndaLawLhsTsDeferred271v | a bound module instance (one target, two targets) | the BREAK under the law; fix: vn28 fullname -> depth (0 away), vn20 stage 1 -> depth, vn20_el stage 1 -> STRICT_EQUAL |
| VN/vn27_bind_literal_control | § ndaConstRhsFreshLhs271 | the base's literal branch in a bound instance | stage 1 on all three binaries (residue 3) |
| VN/vn03, vn05, vn07, vn09, vn17, vn18, vn19, vn22, vn24, vn26 | § ndaConstRhsFreshLhs271 / § ndaImpEnumConstUnlocated271 | enum-typed nets, `inside` on a net, wider and narrower nets, `$unit` enum and parameter, a parameter-reference delay, real and `'1` parameters, an interface in a generate loop, a local enum under two widths, a qualified enum in a width mismatch, enum members with expression initializers | stage 1 on all binaries, 0 away (residues 1, 2) |
| VN/vn01, vn02, vn06, vn08, vn11, vn16, vn25 | § ndaConstRhsFreshLhs271 / § ndaImpEnumConstUnlocated271 | a struct-parameter member, a parameter select, casts, a parenthesized enum, signed negatives, `inside` with a range of parameters, an if-generate block | no verdict change |
| VT/vt01, vt06, vt07, vt09, vt13, vt14, vt21 | § tpUseSharesOwnTs271 | queue / fixed / dynamic / associative-indexed elements, default arguments and ref / output formals, two generics sharing the name T, a three-link chain, members written in macro bodies, foreach locals, a CRLF file | depth -> STRICT_EQUAL (both views) |
| VT/vt24_unit_class_spec | § tpUseSharesOwnTs271 | a `$unit` class | depth -> STRICT_EQUAL (default view) |
| VT/vt08_module_class_spec, vt25_module_class_no_spec, vt26_program_class_spec | § tpUseShareModClassAbstains271v | classes declared in a module or program | the BREAK under the law (vt08, vt26); fix: pristine's bytes |
| VT/vt02, vt03, vt04, vt05, vt10, vt11, vt12, vt15, vt16, vt17, vt18, vt19, vt20, vt22, vt23 | § tpUseSharesOwnTs271 | class typedefs of T, a derived class passing T, keyword defaults, interface classes, a struct member of T, a class in a header included into two packages, out-of-body returns, no default, typedef defaults, inherited T, a value parameter of type T, a keyword chain, multidimensional elements (rc 4 on all binaries: "class array property element"), a class in an interface, specializations as module variables | no verdict change (stage 1 or file on all binaries), 0 chain away |

## Residues on this ground, ranked

1. **The reduced net-declaration constant is not sized.** Golden's `adjustSize` gives the constant the net's width,
   and golden parents a qualified `pk::EA` at the cont_assign:
   - VN/vn07 `wire [7:0] w = LA` (4'hA): golden `vpiSize 8`, ours 4. `wire [1:0] = LB`: golden 2, ours 4.
   - VN/vn24 also leaves the qualified constant without a parent.
   - Stage 1 on all binaries. Both § ndaImpEnumConstUnlocated271 and the base's qualified branch skip the step.
2. **Neighbours § ndaImpEnumConstUnlocated271 does not reach** (stage 1 on all binaries):
   - A parenthesized `(EB)` (vn08): golden `UINT:9`, size 4, consttype 9.
   - A `$unit` localparam read bare (vn09): golden `UINT:7` at the net width; ours a ref_obj.
   - Enum-typed nets `wire e_t w = EB` (vn03): golden writes no cont_assign for these nets at all.
3. **The base's literal and operation clone branch in a bound instance** (vn27) leaves the fresh Lhs without a typespec,
   the shape the verifier's fix covers on the law's branch.
4. **The shared type-parameter typespec's vpiParent.** Golden parents it at a declaring `class_var` or at the last
   type_parameter of a chain; ours parents it at T. Invisible to both comparators, it shows only as dump-line losses
   on stage-1 cases.
5. **The modport port view of a cloned interface net** (vn21): golden's net and its ref_typespec carry the bare name,
   ours `work@dut.u_s.i.mp.w_q.w_q` (8 fullname records).
6. **Module and program classes.** The sharing law abstains there until the specialization listing (pass 269's
   VU/vu04) matches golden.
7. The implementer's own residues stand as listed in r11u271repro/README.md:
   - the `localparam type` struct with an array variable;
   - N/n08's definition view, N/n14 and N/n16;
   - T/t06;
   - pass 269's base type_parameter span.

Sister-ground faces, as the implementer decoded them and reproduced here on the law sweep:
- the `inside`-set package-parameter fold (ExprEmit `emitExpr`): all 6 SeqDriver records and MiniAmiq
  #227043 / 46 / 49;
- MiniAmiq #217949, the `$sformatf` endcol with a macro last argument (ExprEmit);
- MiniAmiq #227149, the cast to `uvm_severity_type` binding an alias clone with a null alias (ParamEmit
  `emitPackage` and ExprEmit).

## Process

- Every corpus path list was fence-filtered by `$FENCED` (read from r11u107repro/canaudit.sh) before any file was
  opened. byteverify ran on hard-link mirrors, and the census used the fence filter.
- One early `grep` of canaudit.sh's `FENCED=` line printed the four names to this agent's own terminal (a read of the
  fence list, not of any fenced source). Nothing fenced was dispatched, read or decoded outside the gate sweeps.
- **The first probe byte compare was unusable.** It compared the law sweep's probe databases, run from this pass's
  law worktree, against the pristine sweep's, run from the pristine worktree. Every database embeds its case path, so
  all 4087 differed. The pristine probe stage was rerun from the law worktree into `/tmp/v11u271_wdQ`, and the 133
  movers above come from that run.
- Only processes this pass started were signalled, after checking each pid's command line for the pass name:
  - the first fix census and the first fix grid, both stopped when the fix gained its second refinement;
  - their outputs, deleted unread, then rerun on the final binary.
- The fix's census was frozen (`evidence/predict_fix.txt`, empty, md5 in `predict_fix.md5`) before the fix sweep. It
  has a positive control: `evidence/predict_fix_positive_control.txt` shows the trace firing on vn28 and vt08.
- Both the law and the fix sweeps exit 1 on the law-index check alone, because the fresh cases predate the
  regenerated index.
