# r11v184 — adversarial verification of r11u184: every headline number reproduced; two pristine-right to patched-wrong breaks found on fresh cases and fixed behind their own switches (§ incDecSelTopRestore184v, § tpEnumCaBindsInstVar184v); ACCEPT-WITH-FIX

Verifier of pass r11u184 (pair A, the expression/parameter ground). Base `1eeff71d` (branch matrix-1.87). Worktrees
`/tmp/wt_v11u184` (the patch plus this pass's refinements) and `/tmp/wt_v11u184pris` (pristine), system-deps config,
`-j 2`. The r11u183 decode landed at `459b7cdf` (tools only) after the implementer started; its `tests/LAWS.md` edit makes
the r11u184 patch's `tests/LAWS.md` hunk conflict at that HEAD (the `src/` hunks apply clean there): regenerate the law
index at integration.

## Verdict

**ACCEPT-WITH-FIX.** Every headline number of r11u184 reproduces bit for bit on binaries built here. Fresh cases found
two breaks where pristine was right and the patched binary wrong, on legal SV. Both are fixed in
`/tmp/r11u184.verified.patch` behind their own switches:

1. **§ incDecSelTopRestore184v** (`src/ExprEmit.cpp`, switch `R11V184_IDTOP_OFF`). § incDecMemberSelIsLvalue184
   records the operand in a pointer that every unary operator cleared on exit. A unary index inside the operand
   (`s.f[~j]++`, `--s.f[-j]`, `s.f[!c]--`) therefore cleared it before the member-chain builder read it. In a function
   or task the index then lost the path naming of § hpTrailSelIdxNamesByPath133: golden and pristine have
   `work@top.bump.s.f[~j].f.j`, the law had `work@top.bump.j` (6 fullname records enter; `cases/I/vi01`, `vi04`). The
   pointer is now restored to its saved value.
2. **§ tpEnumCaBindsInstVar184v** (`src/ParamEmit.cpp`, switch `R11V184_TPCA_OFF`). § tpEnumCopyAtTypedef184 unparents
   the type-parameter enum copy when a continuous assignment writes a whole `T` signal. It scanned only the child's
   top-level continuous assignments. A continuous assignment inside a generate block of the child (`if (1) assign so =
   si;`, two levels down too) left the copy named through the parameter, `work@top.v.T.ie_t`. Golden and pristine have
   `ie_t` (3 fullname records enter; `cases/T/vt02`, `vt13`).

   The rule is transcribed from Surelog's `UhdmWriter::writeCont_assign`. That writer is called for every
   continuous assignment of an elaborated module instance and of its generate scopes (`writeElabModule`,
   `writeElabGenScope`, `writeElabInterface`). It binds a simple-name target with `CompileHelper::bindVariable(mod, m,
   name)`, which walks the scope's parent chain to a `module_inst` and reads its `Variables()`, then its `Nets()`. It
   then runs `tps->VpiParent(nullptr)` on the typespec of the bound object, taken only when that object is an `expr`.
   The refined law unparents when a continuous assignment anywhere in the child writes a variable declared in the
   module body whose type is `T` or a packed array of `T`:
   - a packed array counts: `T [1:0] r` in vt09, golden `ie_t`;
   - a net does not: `wire T w; assign w = si;` in vt12 is parented in golden;
   - a generate block's own variable does not: vt11 is parented, because `bindVariable` never reads a generate scope;
   - an interface child never unparents: vt07 is parented, because `bindVariable` has no `interface_inst` branch.

   The last three were wrong on both binaries and now reach golden's names.

`R11U184_OFF` still restores pristine bytes on every case, and so do the refinements, which are inert under it.
`R11V184_OFF` drops both refinements and gives the law's bytes on every case.

## Binaries (frozen `chmod 555` in `/tmp/v11u184_bin` before any measurement)

| binary | md5 | what |
|---|---|---|
| `pris.bin` | `d0519110f1f72bc00dcc51de37f89dd0` | worktree build of `1eeff71d`, byte-identical to the main tree's `build/slang-uhdm` (the first attempt was OOM-killed when both builds ran in parallel; rebuilt alone) |
| `law.bin` | `36605bc183cbcf047b7158703972e1c1` | `/tmp/r11u184.patch` applied to a fresh `1eeff71d`, byte-identical to the implementer's `fin1.bin` |
| `ver1.bin` | `2361e8a3c305b1a4cc006d77cd2553b7` | law + the two refinements (sweeps `swV`, `swD`) |
| `ver2.bin` = `ver.bin` | `f26442d02aac0dd414e4345623466d48` | ver1 + one trace line on the declined branch of § tpEnumCaBindsInstVar184v (`V184 TPCA keep-parented`); the final `/tmp/r11u184.verified.patch` (sweeps `swF`, `swG`) |
| `uhdm-strictcmp` | `5d4617d0458f34aa79e0b91009d5d1fc` | = the main tree's |

Every sweep's `cmds.txt` names its own binary on all 3273 `slang:` lines: `/tmp/v11u184_swP` has `pris.bin`,
`/tmp/v11u184_swL` has `law.bin`, `/tmp/v11u184_swV` has `ver1.bin` and `/tmp/v11u184_swF` has `ver2.bin`. The
workdir names all have the same length.

**The fence.** `drivers/env.sh` reads the four names from `tools/probe/r11u107repro/canaudit.sh`'s `FENCED=` line and
refuses to run without four. `drivers/vgrid.sh`, `vswitch.sh`, `dscases.sh` and `probemovers.sh` refuse a fenced path
(word boundary). The byte verifications run on hard-link mirrors from r11u184's `drivers/bvmirror.sh`; the corpus
mirrors report `fenced_skipped=8`. The trace census ran `verify_golden.py --filter` on named, non-fenced rows only, and
each filter was checked against `$FENCED_RE` before dispatch. No gdb was run, and no fenced source or database was
read.

## Reproduction of r11u184's headline numbers (law.bin, sweep `swL`, all four stages)

| stage | implementer (swF) | reproduced (swL) |
|---|---|---|
| probe | 0 reg / 3 conv / 3 changes, EQUAL 2889 STRICT_NOTEQUAL 1198 | identical: the same 3 conversions (`r10buvm21repro/g21c`, `r10earl_repro/qa23`, `r11u108repro/grid/f5/f5a07_enumelem`) and the same 3 changes (`g143_c_index endcol(7) -> file(4)`, `c2_idxkind file(9) -> file(8)`, `k9b endline(6) -> endline(4)`) |
| surelog | 0 / 0 / 9, CMP_EQUAL 455 + 451 | identical: the 9 UVM changes, each 2 fullname records fewer |
| uhdm2rtlil | 0 / 6 / 0, CMP_EQUAL 786 + 786 | identical (the 6 conversions below) |
| downstream | 803 / 66 / 2 / 0 | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0; `downstream.csv` byte-identical to `results/downstream_uhdm2rtlil.csv` |
| corpus byte movers | 17 / 2560 | 17 / 2560, the same 17 paths (SELFCHECK 2559 / 2560) |
| probe byte movers | 6 | 6, the same 6 (path-normalised dumps, `drivers/probemovers.sh`) |
| canaries | surelog ok=45 changed=7; u2r ok=16; ctcan2 PASS both | identical |
| law census | Earlgrey_0_1 GENENUM 25 per mode, ibex_multdiv_fast 11, UVM INCDECSEL + LVIDXSEL (BuildUVMPkg + STREAMRD member), TypeParameter rows TPENUM | identical (`evidence/trace_census_moving_rows.txt`) |
| grid + boundary | 112 case-modes to STRICT_EQUAL, 0 records enter | r11u184's 70 cases plus every case of r11u181repro, r11v181repro, r11u178repro and r11v178repro (608 case-modes, both views): STRICT_EQUAL 246 -> 358 (+112), **0 records enter, 0 AWAY** |

The pristine sweep `swP` reads 0 / 0 / 0 in probe, surelog and uhdm2rtlil against the committed baselines: probe EQUAL
2886 / STRICT_NOTEQUAL 1201; surelog CMP_EQUAL 455 + 451 with CMP_NOTEQUAL 3 + 3; uhdm2rtlil 783 + 783 with 1 + 1.
Earlgrey_0_1 default moves TOWARD golden by order-blind distance (ids stripped): 385227 -> 385090 lines.

Every sweep here exits 1, but only for `law index STALE`. Pristine is stale at a clean `1eeff71d`; the law and
verified worktrees are stale because this directory's new cases were present before the regeneration. The final
patch's `tests/LAWS.md` is regenerated and reads current on a fresh apply (last section).

## The breaks (fresh cases, `cases/`, 68 cases x both views = 136 case-modes; `evidence/grid_*.txt`)

Goldens come from the pinned Surelog with and without `-elabuhdm` (`drivers/vgrid.sh`). Each case-mode is judged by
uhdm-cmp line count, by uhdm-strictcmp with `MAX=100000` (record movement uses r11u184's `recmv.py`), by order-blind
dump distance to golden (`drivers/vobdist.py`: ids and paths stripped), and by the downstream verdict
(`drivers/dscases.sh`).

| case | pristine | law | verified | face |
|---|---|---|---|---|
| I/vi01_unary_index (d, e) | col(24) | **fullname**: 24 leave, 6 **enter** | STRICT_EQUAL | `s.f[~j]++` in a function, `s.f[!c]++` in a task: the index name |
| I/vi04_unary_func_only (d, e) | col(12) | **fullname**: 12 leave, 6 **enter** | STRICT_EQUAL | same, minimal |
| T/vt02_gen_ca (d, e) | file(3) | **fullname**: 3 leave, 3 **enter** | STRICT_EQUAL | a generate block's `assign so = si;` |
| T/vt13_gen_if_nested_ca (d, e) | file(3) | **fullname**: 3 leave, 3 **enter** | STRICT_EQUAL | the same two generate levels down |
| T/vt09_packed_arr_only (d, e) | endline (walk diverges) | endline, name `work@top.v.T.ie_t` (golden `ie_t`) | endline, `ie_t` | `T [1:0] r; assign r = {si, si};` |
| T/vt05_packed_arr_ca (d, e) | endline (walk diverges) | endline | endline, order-blind 49 -> 45 | packed array of T plus a concatenation target |
| T/vt07_iface_child (d, e) | stage 1 | stage 1, `ie_t` | stage 1, golden's `work@top.b.T.ie_t` | an interface child: golden parented |
| T/vt12_wire_ca (d, e) | stage 1 | stage 1, `ie_t` | stage 1, golden's `work@top.v.T.ie_t` | `wire T w; assign w = si;`: golden parented |

Totals over the 136 fresh case-modes:
- **Pristine to law:** 115 move. 111 move TOWARD golden order-blind and 2 AWAY (vt17 below). 521 records leave and
  **40 enter**.
- **Pristine to verified:** 115 move. 111 move TOWARD and 2 AWAY. 521 records leave and 4 enter; the 4 are vl02's two
  views, which leave stage 1 (uhdm-cmp NOT_EQUAL on pristine) for judge-equal and expose 2 pre-existing fullname records
  each. STRICT_EQUAL goes from 6 to 55.
- **Law to verified:** 16 case-modes move, all TOWARD golden. 30 records leave and 0 enter.

**Downstream verdicts of the fresh cases** (pristine to verified, `evidence/downstream_cases_pristine_vs_verified.txt`):
- 46 stay IDENTICAL.
- 6 go EQUIVALENT to IDENTICAL (vc01, vc03, vc04, vc08, vc09, vs01).
- 11 stay EQUIVALENT.
- 3 stay DIVERGENT (vt01, vt11, vt17: Surelog's stage-1 faces on the same verdict with every binary).
- 2 stay STATUS_DIFF.

None leaves IDENTICAL.

Faces the laws hold on (fresh instances, law = verified bytes):
- **§ genLocalEnumConstShared184:**
  - holds on two identical instances, a compilation-unit enum with a block variable, a generate case and if/else, two
    sibling blocks declaring same-named enums, and a block localparam of the block enum;
  - abstains on a struct member of an enum, an unpacked array of an enum, a packed array of an enum and a net of an
    enum; golden mints in each, as the `enum_var`-only walk of `lateBinding` predicts.
- **§ incDecMemberSelIsLvalue184:** holds on expression-position and condition increments, a generate-for body with a
  genvar index, a nested member, an implicit-this class property, a handle chain, inout and ref formals, and an
  automatic local.
- **§ hpIdxCallNameSpan184:**
  - holds on a call inside a member path that is itself a non-trailing index (golden also spans the name there),
    a path that is a call argument, two non-trailing dimensions, a continuous assignment, a generate-scope process, a
    class method's own method and a named argument;
  - a call in an lvalue index is left alone, and pristine and law are byte-identical there.
- **§ rootLvalueSpanAtRoot184:** holds on an intra-assignment delay, a bit select read from a local, a function body and
  a generate scope's process with an indexed target.
- **§ genScopeTrailSelNameLate184:** holds on a generate-for with a genvar index and a named begin with a local index.
- **§ lvIdxMemberSelIsRead184:** holds on two member-select indices and on a function with an indexed part-select.
- **§ memberSelParenIdxSpan184:** holds on double parentheses, a parenthesized operand of an operation, a nested member,
  a condition, a continuous assignment and a macro index. The lvalue and inc/dec controls keep their shape.

## Gates of the verified binary (`ver2.bin`, sweeps `swF` probe + corpora and `swG` downstream)

| gate | result |
|---|---|
| (1) build | pris `d0519110...`, verified `f26442d0...`; the verified patch applied to a fresh `1eeff71d` builds to exactly `f26442d02aac0dd414e4345623466d48` |
| (2) probe | regressions=0 conversions=3 changes=3; EQUAL 2889 / STRICT_NOTEQUAL 1198. The 3 conversions and 3 changes are r11u184's own, and `probe.csv` is byte-identical to swV's |
| (3) corpora | surelog 0 / 0 / 9 (the 9 UVM `fullname -2` changes); uhdm2rtlil 0 / **6** / 0. Both csvs equal swV's except the LowMemLib log-path text |
| (4) downstream | 803 IDENTICAL / 66 SLANG_REJECT / 2 EQUIVALENT / 0 DIVERGENT, not excused 0. `downstream.csv` is byte-identical to `results/downstream_uhdm2rtlil.csv`. Slang-lane databases: 0 / 805 movers against the law sweep (SELFCHECK 804 / 805) |
| (5) uhdm-cmp | every touched row-mode and probe case keeps a judge-equal status (CMP_EQUAL / STRICT_NOTEQUAL / EQUAL): uhdm-cmp reads 0 lines on each |
| (6) byteverify | verified vs pristine: the same 17 / 2560 movers as the law. Verified vs law: 2 / 2560 (MiniAmiq d and t), each 4 order-blind lines `UINT:0 / UINT:540` (t: `1117`) with `vpiDecompile`, the known UVM order coin. ver1 vs law showed 5 coins (MiniAmiq d/t, Scoreboard d at 0 lines, SeqDriver d, SimpleUVM d), all the same 4-line coin |
| canaries | `canaries.sh` surelog ok=45 changed=7 (exactly the claimed UVM changes), uhdm2rtlil ok=16 changed=0; `ctcan2.sh` surelog PASS (EXPECT_UNKNOWN=1), uhdm2rtlil PASS (EXPECT_UNKNOWN=6) |

**CONVERSIONS (quoted from `/tmp/v11u184_swF/uhdm2rtlil.csv`; results/ untouched):**

    ibex_multdiv_fast,default,CMP_EQUAL,,,equal
    ibex_multdiv_fast,testflags,CMP_EQUAL,,,equal
    TypeParameterAsPortTypeWithEnum,default,CMP_EQUAL,,,equal
    TypeParameterAsPortTypeWithEnum,testflags,CMP_EQUAL,,,equal
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,default,CMP_EQUAL,,,equal
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,testflags,CMP_EQUAL,,,equal

and from `/tmp/v11u184_swG/downstream.csv`:

    ibex_multdiv_fast,IDENTICAL,OK,OK,3906,3906,,
    TypeParameterAsPortTypeWithEnum,IDENTICAL,NO_GATES,NO_GATES,0,0,,
    TypeParameterAsPortTypeWithEnumOfParametrizedWidth,IDENTICAL,NO_GATES,NO_GATES,0,0,,

**Movers of the refinements, bounded before the sweep.** Both refinements are reachable only inside a firing law:
- § incDecSelTopRestore184v needs the pointer that § incDecMemberSelIsLvalue184 sets;
- § tpEnumCaBindsInstVar184v sits inside the `law184` branch of § tpEnumCopyAtTypedef184.

Their corpus movers are therefore a subset of the law's firing rows. The trace census of those rows through `verify_golden.py --filter` (`drivers/tracewrap.sh`; the 3 u2r rows and the 6 surelog rows, both modes; `evidence/trace_census_moving_rows.txt`) prints no `V184` line. The prediction is 0 real corpus movers, and it holds: the byte verification reads 2 movers, both the UVM order coin. The probe databases of `swV` equal `swL`'s byte for byte (0 / 4087).

**Switch matrix** (`drivers/vswitch.sh`, `evidence/switch_matrix.txt`; this pass's 68 cases plus r11u184's 70, both
views, 276 case-modes):
- `R11U184_OFF=1` on the verified binary writes the pristine bytes on all 276.
- `R11V184_OFF=1` writes the law's bytes on all 276.
- The verified binary differs from the law on exactly 16 case-modes, each with a `V184` trace line.
- On those 16, `R11V184_IDTOP_OFF` alone reverts exactly the two I cases, and `R11V184_TPCA_OFF` alone reverts exactly
  the six T cases.

## Residues, ranked (this ground)

R1. **A positional type override** (`sub #(ie_t) v (...)`, vt17): Surelog does not apply it, and golden types the ports
`logic` with no enum copy. Ours builds the copy, and § tpEnumCopyAtTypedef184 now locates it: stage 1 on every binary,
AWAY by 4 order-blind lines. This is a Surelog defect shape; no fence is proposed.

R2. **A compilation-unit enum read in a generate-scope process with no block variable** (ve11, definition view):
golden binds the shared located constant through `lateBinding`'s file typedef map (`fC->getTypeDefMap()`), and ours
mints. A one-branch extension of § genLocalEnumConstShared184 (the enum's typedef is declared in the compilation unit).
The elaborated view is already equal.

R3. **A streaming lvalue whose operand is a member path ending in a select** (`{>>{s.f[k]}} = x`, vs01, vs02): the
member-chain builder still takes the lvalue shape (golden: base at its own token, select named `work@top.s.f[k].f`).
§ streamLvMemberPathRead184 covers only the mixed-path, plain-select and select-free member builders.

R4. **A path nested in another path's index** (`s2.g[s.f[i]] = 1`, `s2.g[s.f[i]]++`; vl01, vl02): golden names `i`
through the outer path (`work@top.s2.g[].g.s.f[i].i`), and ours through the inner. This is pass 178's h09 family on
every binary. vl02 leaves stage 1 by the laws and now shows exactly these records.

R5. **A package-qualified call in a non-trailing index** (`m.w[pk::g(k)].v`, vc02): golden spans `pk::` (20-24), and
ours spans `pk` (20-22) on every binary.

R6. **A typedef of a typedef as a type override** (`typedef ie_t je_t; .T(je_t)`, vt03): golden's copy is `ie_t`'s,
located and named at the inner typedef. Ours is named `je_t` and now located at `je_t`'s typedef: stage 1 on every
binary (order-blind SAME).

R7. **`$root` targets with two dimensions or a part select** (vr04, vr05): golden builds a `ref_obj` plus
`var_select` / `part_select` shape with its own names. The hier_path span now matches golden, and the element shape is
stage 1 on every binary. § rootLvalueSpanAtRoot184's stored text on the two-dimensional pristine `bit_select`
(`arr[1][2]`) is on a shape golden does not have.

R8. **r11u184's own residues stand as its README ranks them:**
- FuncStructValSimple (sister N0080);
- Scr1SvTests `type(1)`;
- rt/g06;
- the index names under trailing selects;
- two-dimensional member selects;
- the modport parenthesized index;
- the unsized literal continuous assignment (ModuleEmit).

Sister-ground faces (report only): as r11u184's S1-S4. The interface child and the net target of
§ tpEnumCaBindsInstVar184v are ParamEmit decisions and are landed here.

## Files

- `cases/` (every case names its laws in its first line):
  - `E`: § genLocalEnumConstShared184; ve06, ve09, ve10 and ve11 are controls.
  - `T`: § tpEnumCopyAtTypedef184 and § tpEnumCaBindsInstVar184v; vt14 is the control.
  - `I`: § incDecMemberSelIsLvalue184; vi01 and vi04 also § incDecSelTopRestore184v.
  - `L`: § lvIdxMemberSelIsRead184.
  - `S`: § streamLvMemberPathRead184.
  - `C`: § hpIdxCallNameSpan184.
  - `P`: § memberSelParenIdxSpan184; vp02 is the control.
  - `G`: § genScopeTrailSelNameLate184.
  - `R`: § rootLvalueSpanAtRoot184.
- `drivers/`:
  - `env.sh`: pins and `$FENCED`.
  - `vgrid.sh`: the golden (cached per case text), the binary, uhdm-cmp, strictcmp and dumps, for either view.
  - `vjoin.sh`: the verdict, bytes, record movement and order-blind direction between two binaries.
  - `vobdist.py`.
  - `vswitch.sh`: the switch matrix.
  - `dscases.sh`: downstream verdicts through `scripts/downstream_uhdm2rtlil.py`'s `one()`.
  - `probemovers.sh`: path-normalised probe movers.
  - `tracewrap.sh`: the census wrapper.
- `evidence/`:
  - the sweep logs: `swP` pristine, `swL` law, `swV` ver1, `swD` ver1 downstream, `swF` ver2, `swG` ver2 downstream;
  - the byte verifications, the probe movers, the grid joins, the switch matrix, the downstream verdicts of the cases,
    the canaries and the census.
