# r11u272 — the expression/parameter ground: the EvalFunc-leftover struct copy, twenty-one probe conversions

Pass 272, implementer, pair A (refill after pass 270), base 888e916b. One law in ParamEmit behind `src/R272.h`
(`R11U272_LOTSCOPY_OFF`; `R11U272_OFF` drops it and gives pristine's bytes on every grid case-view;
`R11U272_TRACE=<dir>` logs every firing and abstention). No corpus row changes verdict (there is no corpus row left
on this ground: MiniAmiq d/t is the only STRICT_NOTEQUAL corpus row and both of its records are the sister's).
**TWENTY-ONE PROBE CONVERSIONS**, one probe change toward golden, 0 regressions in every stage.

## Verdict per targeted row

| row / bucket | before (base) | after |
|---|---|---|
| probe bucket "typespec_member / operation / ref_typespec `fullname`" (the map's struct-valued function-call fold in member typespecs, 24 cases) | 24 STRICT_NOTEQUAL | **21 EQUAL**, r11u26repro/m7 `differ:fullname(40) -> differ:fullname(38)`, m4 and r11u28repro/a2 unchanged (a module-local function, residue 2) |
| MiniAmiq d/t | `differ:col(2)` (#241741 / #243118, TaskFuncEmit) | unchanged, bytes identical to pristine (the law does not fire there) |
| probe bucket "`assign o = P` with a struct parameter" (25 cases `differ:name`) | STRICT_NOTEQUAL | unchanged: decoded to ModuleEmit emitContAssigns (sister ground, residue 1) |

The probe conversions (fresh law sweep, `probe.csv` rows read `EQUAL,,equal`): r11u24repro/n12, r11u24repro/n3,
r11u26repro/m12, m13, m15, m6, m8, m9, r11u28repro/a13, a16, a4, a5, a6, a7, r11v26repro/v12, v13, v15, v16, v18,
v2, v9 (each `differ:fullname(2..8) -> EQUAL`; `evidence/sweep_law_summary.txt`).

## The probe residue by writer at the base (item 1)

`evidence/residue_heads_base.tsv`: every one of the 405 STRICT_NOTEQUAL cases with its first record's field and
object chain (uhdm-strictcmp --max 1 against the cached golden, on this pass's pristine sweep). The largest buckets:

| cases | first record | writer | this pass |
|---|---|---|---|
| 25 | `name` at `module_inst / cont_assign / ref_obj` (`assign o = P`, P a struct parameter) | ModuleEmit emitContAssigns (sister) | decoded, reported (residue 1) |
| 24 | `fullname` at `typespec_member / operation / ref_typespec` | ParamEmit stampEvalFuncLeftovers (this ground) | **the law: 21 converted** |
| 21 | `fullname` at `struct_typespec / typespec_member / ref_typespec` (package and class typedef listings, type parameters) | TypeEmit (sister; pass 273's residue 2) | reported |
| 15 | `line` at `packed_array_typespec / ref_typespec / logic_typespec` (type-parameter-sized arrays) | TypeEmit / UhdmExporter (sister) | reported |
| 12 | `fullname` at `operation / constant / ref_typespec` (scattered: interface-array ranges r10rgg4 a1/b1/c1/v5k, generate-scope folds r11v23 v11/x09, r10v64 v7, r10earl95 g5) | mixed, ModuleEmit generate clones and ExprEmit folds | not attempted |
| 10 | `name` at `logic_typespec / ref_typespec / logic_typespec(q2::row_t)` (cross-package alias name) | TypeEmit (sister) | reported |
| 4 | `value` at `param_assign / operation / constant` (r11u109repro f1 c04, c06, p06, p07) | a Surelog defect: `W'(1)` with W = 64 reads `UINT:0` in golden (the 64-bit mask shift), not transcribed | reported |

## The law (src/R272.h)

### § leftoverTsCopyPerElabUse272 — switch `R11U272_LOTSCOPY_OFF` (ParamEmit, design-final, run with the deferred post-passes of stampEvalFuncLeftovers; record in emitParameters)

Surelog elaborates every instance parameter with a clone_tree of its typespec, and the elaborated param_assign's
value is the reduced default with a clone of its own; the clone takes the struct's EvalFunc member leftovers with it
(the typespec_member Actual_value objects the evaluator stamped, § patParamLeftoverShare26), re-parented at the
copy's members. So the leftover operation's ref_typespec names itself through the copy (`work@dut.k0.P.pk::c_t.u`,
`pk::c_t.u`), where ours, sharing the package's typedef listing, named it after the leftover's source param_assign
(`pk`); the strict walk re-expands the typespec at every reference and read `<in>pk::c_t.u` against `pk` at every
elaborated listing. Decoded by identity (`evidence` grid, the tsref census of golden: package and definition
listings bind the original, each elaborated parameter its own copy, the value its own copy):

- every elaborated module instance (the top included, any depth, generate scopes' instances included): a
  parameter's ref_typespec bound to a struct typedef listing (a struct_typespec not under a ref_typespec or a
  parameter) that carries a leftover on a member, or on a member of a nested struct, takes a fresh copy;
- the param_assign's value constant takes a copy only when the instance takes the DEFAULT and the default is a bare
  (imported) or package-qualified name of a PACKAGE parameter: an override keeps the listing (L/l04, l13, l25),
  and so does a value the evaluator computes here (a function call: r11u82repro s1_modform, r11u11repro a5,
  r11u14repro c5, r11u20repro b6) or a module-local name (r11u82repro v2_aliaschain `B_ALIAS = M_LOC`,
  r11vu13repro v4 `E = D`) — those first drafts regressed eight probe cases, each fixed before the final binary;
- the copy: the struct, its members (spans and ref spans), their ref_typespecs named through the copy, nested
  annotated structs copied the same way, and each leftover cloned field for field (constants and operations over
  constants only; any other kind makes the law abstain for that struct and pristine's share stays: trace
  `abstain unclonable`); a member value constant keeps its source's stored full name (s1_modform reads golden's
  empty name), an operand of a cloned operation names itself through the copy (r11v26repro v13);
- a copy we already made (struct_param_func_* style copies under the parameter's or the value's ref_typespec) whose
  member still shares the listing's leftover OPERATION (parented at its source param_assign) gets a clone of it
  parented at the member (r11u26repro m9: the pattern-valued member `n`).

Sites: `grep -n '§ leftoverTsCopyPerElabUse272' src`. Grid `cases/L` (every case's first line names the law).

## Grid (`cases/L`, 26 case dirs, every one § leftoverTsCopyPerElabUse272, both views; drivers/grid.sh, every line carries rc: `evidence/grid.txt` 208 lines, `evidence/grid_summary.txt`)

52 case-views: **48 moving, 25 entering STRICT_EQUAL, 0 leaving, 0 nonzero exit codes, 0 uhdm-cmp verdict
changes, R11U272_OFF == pristine on 52/52, every mover returned to pristine bytes by `R11U272_LOTSCOPY_OFF`.**
Away census on all 48 movers (`evidence/away_grid.txt`; record census where both sides pass stage 1, dump census
otherwise): lost=0 on 48 of 48.

| cases | shape | result |
|---|---|---|
| l01_child_default, l02_top_param, l03_depth2, l05_two_inst, l06_localparam_child | default `pk::C` on a child, the top, depth 2, two instances, a child localparam | fullname -> STRICT_EQUAL both views |
| l04_override, l13_passdown, l25_ovr_name_local | an override (`.P(pk::C)`, passed down by name, a local name): only P copies | fullname -> STRICT_EQUAL both views |
| l11_slots | P in a part-select width, an indexed part select, a bit select and a replication count (the constant slots) | default view -> STRICT_EQUAL; elaborated view fullname(8 -> 3 records), lost 0 |
| l17_macro, l22_genfor, l24_genif, l26_func_always | a macro default, for-generate and if-generate instances, P read in a function and always_ff | fullname -> STRICT_EQUAL both views |
| l12_nested | nested writes `c.u.a = 3` (constant leftovers only) | STRICT_EQUAL on both binaries (bytes move) |
| l07_net_typed | `assign v = P` on a struct net | fullname -> name: the remaining record is the `assign o = P` face (residue 1) |
| l08_import, l15_import_noaa, l09_gen, l10_iface, l14_ovr_pattern, l23_alias, l27_implicit, l28_two_params, l29_modfunc_ovr, l30_ifport, l31_this_class | wildcard import, a generate-local localparam, an interface parameter, a pattern override, an alias typedef, an implicit net, two struct params, a module-function override, an interface port, a class specialization | stage 1 on both binaries (other faces); dump census lost 0 on every one (l29's distance 7 -> 15: our copies repeat the module-function leftover constants pristine already writes wrong, residue 2) |

## Census, sweeps and gates (frozen binaries: pristine md5 0abca796 = the main tree's build, law lawG md5 779f5183)

- Firing census (drivers/tracecensus.sh, run BEFORE the law sweep with the filter built from `$FENCED`):
  `evidence/predict.txt` (md5 in `evidence/predict.md5`), 83 lines; byte movers predicted = every line with a
  firing that is not only an abstention: 57 probe cases, surelog StructParamPatternInitCast d/t, uhdm2rtlil
  def_ctx_struct_param, latch_decoder_partial, latch_tlb_napot, portsel_struct_param, struct_member_cfg_width,
  struct_param_func_arg, struct_param_func_loop d/t. (A census on a first final binary was rerun on lawG after the
  copy's member ref_typespec names were made golden's; the 83 rows were the same.)
- Pristine sweep: probe, surelog, uhdm2rtlil regressions=0 conversions=0 changes=0 (the baseline exactly; probe csv
  byte-identical to results/golden_probe.csv), downstream 803/66/2/0. Law sweep: probe regressions=0
  **conversions=21 changes=1** (EQUAL 3703 + STRICT_NOTEQUAL 384); surelog regressions=0 conversions=0 changes=0;
  uhdm2rtlil regressions=0 conversions=0 changes=0; downstream 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT /
  0 DIVERGENT, the csv byte-identical to pristine's and to results/downstream_uhdm2rtlil.csv. Both sweeps exit 1 on
  the law-index staleness check alone (tests/LAWS.md regenerated last, in the patch). The row-by-row corpus csv diff
  is only the LowMemLib/LowMemPkg testflags workdir path in the detail text (`evidence/sweep_law_summary.txt`).
  - The probe change r11u26repro/m7 `differ:fullname(40) -> differ:fullname(38)`: two records toward golden, chain
    census away=0 toward=4.
- byteverify (fence-filtered hard-link mirrors, drivers/bvmirror.sh, SELFCHECK=1): PATH_SETS_IDENTICAL 2560,
  **MOVERS 16 / 2560 = exactly the 16 predicted** (`evidence/byteverify_corpus.txt`), every one CMP_EQUAL on both
  binaries with uhdm-cmp 0 lines. SELFCHECK reads 2559 / 2560: every file is compared against one fixed file, which
  is the one not flagged (a self-check artefact, not a mover). The predicted abstention-only rows
  (FuncStructValSimple d/t and the 4 probe s1_modform-style cases) do not move. Probe: **57 of 4087 databases move =
  exactly the 57 predicted** (`evidence/byteverify_probe.txt`). Downstream: 7 of 805 slang-lane databases move (the
  seven predicted uhdm2rtlil tests), their RTLIL (`.il`, `_nohier.il`, `_synth.v`) byte-identical on both binaries,
  all IDENTICAL (`evidence/byteverify_downstream.txt`).
- Away-moved census (chain-keyed, drivers/awaychain.py with strictcmp_x): away=0 on all 16 corpus movers
  (toward 1-6 each) and all 57 probe movers; positive control: the same census with the binaries swapped on
  r11u26repro/m12 reads away=8 (`evidence/away_*_movers.txt`).
- Canaries: surelog ok=52 changed=0, uhdm2rtlil ok=16 changed=0; ctcan2 PASS on both (`evidence/canaries.txt`).
  Binary-path audit: 3273 of 3323 cmds.txt name the sweep's own binary, the other 50 carry no slang line.
- Determinism (drivers/det.sh, three concurrent draws of Earlgrey_0_1, the five UVM rows and Rggen, both modes): one
  hash per row-mode, equal to the law sweep's (`evidence/determinism.txt`).
- MiniAmiq d/t: bytes identical to pristine; the composite heads stay #241741 / #243118 (no record of this ground
  behind them).
- Byte controls (drivers/controls.sh, path lists filtered by `$FENCED` first): 26 earlier repro dirs (r11u118repro,
  r11v11u118repro, r11u119repro, r11u120repro, r11v120repro, r11u124repro, r11v124repro, r11u131repro, r11v131repro,
  r11u24repro, r11u26repro, r11u28repro, r11v26repro, r11u232repro, r11u227repro, r11u82repro, r11u109repro,
  r11u13repro, r11vu13repro, r11u16repro, r11u167repro, r11v167repro, r11u270repro, v11u270repro, r11u273repro,
  v11u273repro): 2620 case-views, **132 moving, 16 entering STRICT_EQUAL** (r11u167repro pc c01_el, c02_el, c09_el;
  r11u227repro PL pl08 and pl10 both views; r11u26repro m1 both views, m2; r11u28repro a1, a11, a14 both views),
  **0 leaving, 0 exit-code changes**; the away census lost 0 on all 132 movers (`evidence/controls_summary.txt`,
  `evidence/controls.txt`). uhdm-cmp line count changes on 4: r11vu13repro v3 and v10 in both views, 308 -> 320
  lines, stage 1 on both binaries with the same first difference (the extra lines print the copy's parent chain);
  their dump census lost 0, distance 2 -> 9: `localparam p::ucfg_t Cut = p::C` reads a cfg_t value into a
  ucfg_t parameter and the law copies its value's typespec, which golden's stage-1 database cannot confirm
  (residue 3).

## Residues, ranked

1. **Sister ground, `assign o = P` with a struct parameter (25 probe cases, r11u108repro pk k10*, k11, r11u111repro
   f2 b03-b17, v11u111repro x22 / x26; grid L/l07).** Decoded with fresh cases: a struct parameter whose default is a
   package parameter NAME whose value is a constant (`localparam p::s_t P = p::D`, D `16'hbeef`) reduces in golden's
   writeCont_assign to the param_assign's value object (shared, not listed at the assignment), where ours keeps the
   definition's `ref_obj P`; with a literal default (`= 16'hbeef`) or a pattern-valued D both share the definition
   ref_obj and agree. The decision is ModuleEmit emitContAssigns's elaborated NamedValue branch ("A whole STRUCT/UNION
   typed param ref stays a shared ref in the elab CA"), the sister's ground; § paramValRhsSharesParamConst273 is the
   share law that would then apply. Not written here.
2. The module-local-function leftovers (r11u26repro m4, m7, r11u28repro a2; grid l29): the leftover's source is a
   module localparam / module function; the head is the leftover op's ref_typespec named `work@dut` where golden has
   none, then a walk divergence; not decoded.
3. A converted value (r11vu13repro v3 / v10, `localparam p::ucfg_t Cut = p::C`): stage 1 on both binaries, the law's
   value copy unconfirmed (dump distance 2 -> 9, lost 0); the narrower rule (copy only an unconverted name) is the
   candidate refinement once the stage-1 face is cleared. Grid stage-1 shapes on both binaries: an interface parameter (l10), a generate-local localparam (l09), wildcard
   import with a module-local read (l08, l15), a pattern override (l14), an alias typedef (l23), implicit nets, two
   struct params, interface ports and class specializations (l27, l28, l30, l31).
4. The remaining probe buckets in the table above (sister-ground ones reported there), the r11u109 64-bit cast value
   defect, and the brief's items (2) to (7) other than the r11v270On helper: not attempted.
5. The brief's item (2) cleanup is done: `src/R270.h`'s unused `r11v270On` helper is removed (no byte effect; the
   final binary was rebuilt after it). Item (4)'s README note: pass 266's README says § sgnLitElabFreshIntTs266 fires
   in "a module or interface home" where the code tests not-a-package (program, generate and class homes too) —
   recorded here, their README untouched.

## Sister-ground faces (reported, not written)

- TaskFuncEmit: the constructor return class_var span, MiniAmiq's last face (#241741 / #243118, r11u270repro C/c01).
- ModuleEmit emitContAssigns: the `assign o = P` struct-parameter fold (residue 1).
- TypeEmit: struct member ref_typespec full names in package/class typedef listings and type parameters (21 probe
  cases), the type-parameter-sized packed-array typespec line (15), the cross-package alias name (10).

## Process notes

- Seven law binaries preceded the final one (law1-law7, lawF): law1/2 missed the existing-copy case (m9); law3's
  probe sweep read 8 regressions (the value copy on function-call and module-local defaults) fixed by restricting the
  value copy to package-parameter names; law4-7 fixed the full-name storage of cloned constants; lawF's census and
  sweep were stopped (own background task, no other process) when the copy's member ref_typespec names were changed
  to golden's, and every number above is from lawG.
- One of my own waiters used `pgrep -f` with a pattern its own command line contained; it never ended and was
  stopped by its own task id (nothing else signalled).
- No fenced test was dispatched or read outside the gate sweeps; the census ran with the `$FENCED` filter; every
  corpus path list was filtered by `$FENCED` before any file was opened; byteverify and the away census ran on
  fence-filtered mirrors.
