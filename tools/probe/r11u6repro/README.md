# r11u6 — the ibex package-parameter family: THREE laws, 0 conversions

Base commit `7ae0ce08`. Pristine build md5 `75b2098c608dd7ebd50199dd1c27ccbb`
(byte-identical to the main tree). Patched build md5
`0c071d12283ce9955fe9c0d53db9363e`. Everything here is measurement-only; the
judge is `uhdm-cmp` through `scripts/verify_golden.py`.

**SAID LOUDLY: this pass converts ZERO rows.** Both corpora, both modes, every
row's status and dump column is byte-identical to the committed baseline. What
it does is clear the *entire* package-parameter typespec family out of
`ibex_pkg` on ten rows: nine cluster-A rows' shared head at
`ibex_pkg.sv:721:40` and `ibex_tracer`'s at `772:20` are both GONE, and eight
of the nine now wear the SAME head the three cluster-B rows already wore
(`prim_assert.sv:33:10`, the ``PRIM_STRINGIFY`` residue). `results/*.csv` are
NOT edited — there is nothing to promote.

## 1. What r11u5 left, and what re-measuring corrected

r11u5's R0/R1 framing said golden's two elaborated copies are "(reduced,
symbolic)" and ours "(half, half)", read off a dump-order census. Read off the
OBJECT POINTER instead (`tsedge.cpp`, which interns the `Actual_typespec` of
every listing's parameters), the real grid is a four-cell table per parameter
and the defect is not a swap — it is that we never reduce at all, and that our
def-listing copy folds something golden keeps symbolic.

`g1`'s package parameter `PermDflt`, typed by
`typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t`:

| listing | GOLDEN | OURS at 7ae0ce08 |
|---|---|---|
| allPkg (the package's own DEF listing) | `[operation, operation/clog2arg=ref_obj]` | `[operation, operation/clog2arg=`**`constant`**`]` |
| topPkg (the ELABORATED package listing) | `[constant, constant]` | `[operation, operation/clog2arg=constant]` |
| allMod (the module DEF listing) | `[constant, constant]` | `[operation, operation/clog2arg=constant]` |
| topMod (the module ELAB listing) | `[constant, constant]` | `[operation, operation/clog2arg=constant]` |

So there is no inversion to undo: golden keeps ONE symbolic copy (the def
listing's) and reduces the other three, and even that one symbolic copy keeps
its `$clog2` ARGUMENT as a bare `ref_obj` where we substitute a folded
`constant UINT:32`. r11u5's "our own package DEF listing gets this right"
was true of the TYPEDEF LISTING object (`p::lfsr_perm_t`, byte-identical to
golden on both sides) and false of the PER-PARAMETER CLONE, which is the
object the head names.

## 2. The three laws

### § pkgParamDefTsQueryArgRef (TypeEmit, the head)

The deferred DEF-listing drain (`drainDefParamTs`) runs *after* every package
is emitted, so `curPkgEmitSym` is already null there. § sysCallArgPkgParamSubst
— the MODULE half of the query-call rule, which substitutes a package
parameter's value for the argument — is guarded by `!curPkgEmitSym`, so it
swallowed the def-listing clone too and folded a read Surelog keeps symbolic.

`paramTsOwnPkgDefSym` (new; set beside the existing `paramTsOwnPkgDefView`) is
the drain's stand-in for `curPkgEmitSym`, so the direct and the deferred path
now ask ONE question: *is this the parameter's own package DEF listing, and
does the argument name a parameter of that same package?* If yes, the argument
falls through to the bare `ref_obj` — exactly what golden emits, over the
identifier's own span, with no `Actual_group`.

Head, before: `ref_obj (…lfsr_perm_t::LfsrWidth)` at `ibex_pkg.sv:721:40`
against our `constant UINT:32` carrying a `ref_typespec → int_typespec`.

### § pkgParamVecTdCloneViewFold + § pkgParamVecTdCloneAliasView (ParamEmit)

The VECTOR (`logic`) typedef clone was the one builder of a package
parameter's declared range still hardcoding `tfContext = true` (both arms —
the main clone and the materialized-import second clone). It now reads
`pkgParamOwnDefView(ps)`, the same predicate the scalar `bit`/`int`/`byte`
clone and the inline (non-typedef) range arm already read. **This is the
change r11u5 measured as INERT and reverted.** It is inert *alone* because it
fixes the divergence behind the head; with § pkgParamDefTsQueryArgRef in front
of it, the pair moves the head.

Fixing the fold immediately exposed a second, older defect the old head had
masked: the clone's `Typedef_alias` was resolved through `typedefTs`
unconditionally, so the ELABORATED listing's clone aliased the DEF listing's
typedef object. `typespec::Compare` walks `Typedef_alias` before `Instance`,
so that object's still-symbolic bound became the head the instant the fold
cleared (g1: golden `constant INT:31` at `4:18`, ours the `LfsrWidth-1`
operation). The clone now prefers `pkgTopTypedefTs` outside the def view, the
way the scalar arm already did.

### § pkgParamUnpackedElemDefRange + § pkgParamUnpackedElemFoldConst (ParamEmit)

Once R0/R1 cleared, all nine cluster-A rows fell onto `ibex_tracer`'s own head
at `ibex_pkg.sv:772:20` — `parameter logic [PMP_ADDR_MSB:0] PmpAddrRst[PMP_MAX_REGIONS]`.
An UNPACKED-ARRAY package parameter hangs its declared PACKED range off the
array typespec's ELEMENT, built by a path that folded that bound in EVERY
view; its SCALAR sibling (`parameter logic [MSB:0] AddrOne`) was always right,
which is why the shape hid. Two halves, both measured on `grid/gF`:

* the parameter's own package DEF listing keeps the symbolic read (a `ref_obj`
  chained to the referenced parameter's def Rhs) — gated to a bound that
  actually READS a parameter, so a literal bound cannot move;
* everywhere else the bound folds to the referenced parameter's OWN value
  constant, re-sized to its declared width and carrying a
  `ref_typespec → <that parameter's typespec>` — `crossPkgBoundFoldConst9`,
  the same substitution the qualified-bound and query-argument rules use.
  Gated to a BARE-NAME bound, the only shape where the range bound's value IS
  the parameter's value.

Golden `[constant]->[ref_obj]` in the def listing and `[constant]->[constant]`
in the other three; ours folded all four at 64 bits with no typespec.

## 3. The golden grid (`GRID.r11u6.txt`, `grid.sh`, `grid/g*`)

Eight arms, every one compiled `--nobuiltin` on the slang side (REQUIRED — the
harness passes it, and without it the builtin package makes the whole design a
vector-size mismatch and the head is noise). Every arm records surelog rc,
both binaries' rc, cmp-line count, head, and the per-listing identity census.
`surelog_rc=0 pristine_rc=0 law_rc=0` on all eight.

| arm | shape | cmplines pris → law | verdict |
|---|---|---|---|
| gA | pkg vector td, `$clog2(<same-pkg param>)` bound | 46 → 36 | head cleared; **census cell-for-cell equal to golden** |
| gB | the same with `$clog2(q::QW)` — a CROSS-package read | 33 → 33 | **NEGATIVE CONTROL holds**: golden substitutes it in the def listing too, and so do we, before and after |
| gC | arithmetic-of-ref bound, no query call | 62 → 17 | fold half alone; census equals golden |
| gD | MODULE-homed typedef + module parameter | 42 → 42 | **NEGATIVE CONTROL holds**: the view law is package-only, census byte-identical pristine↔law |
| gE | LITERAL-bound package vector typedef (class B) | 17 → 17 | alias half moves bytes, judge sees nothing |
| gF | unpacked-array pkg param + its scalar sibling | 34 → 50 | `AddrRst` census equals golden; head advances past it to the scalar sibling (residue R1′) |
| gG | `$bits(TYPE)` argument | 68 → 17 | a type name binds to no NamedValue; neither rule touches it |
| gH | `$clog2(W+1)` — an OPERATOR-tree argument | 98 → 17 | § sysCallArgOperatorTree owns it; neither rule touches it |

gB is the arm that keeps the law honest: its def-listing cell reads
`clog2arg=constant` on BOTH sides while gA's reads `clog2arg=ref_obj` on both
sides after the law. An arm agreeing is not an arm testing — gB agrees for the
right reason, and the census says so.

17 cmplines is these witnesses' pre-existing floor (gE sits there untouched on
both binaries), so gC/gG/gH reaching it is convergence, not masking.

## 4. Census: predicted movers vs measured (`CENSUS.r11u6.txt`, `predict.py`)

`predict.py u2r|surelog` resolves the source list the HARNESS builds
(`project.f`, else `dut.sv`/`dut.v`; the `.sl`'s whole TEST TREE for surelog —
r11u5's predictor walked only each test's own directory and was blind to both
`ibex_*` rows, whose sources live in `../ibex/rtl`, and to `Earlgrey_0_1`,
whose `.sl` sits in `sim-icarus/` over a sibling `src/`). Three deliberately
over-broad classes: **A** symbolic-bound package vector typedef + a parameter
typed by it; **B** the same with ANY bound (the alias half reaches a literal
bound too); **C** a package parameter with both a packed range and an unpacked
dimension.

POSITIVE CONTROL: the scanner returns 5 hits on `ibex_pkg.sv`.

* **u2r predicted: 30 rows** — the 28 `ibex_*`, plus `typedef_package` and
  `2DParameterOfInstance` (both class B).
  **u2r measured: 12 rows × 2 modes = 24 / 1608.** Ten ibex rows (alu,
  branch_predict, compressed_decoder, decoder, icache, multdiv_fast,
  multdiv_slow, pmp, tracer, wb_stage) plus `typedef_package` and
  `2DParameterOfInstance`. Every mover was predicted BY NAME.
  Class B was added *because* the first census named those last two and class
  A did not — their dumps are byte-identical header-stripped (the alias
  re-point changes which object is referenced, not what it says), so the move
  is arena order only and the judge cannot see it. Both rows stay CMP_EQUAL.
  The ten ibex dumps move 903–1625 lines, and EVERY moved cell sits at
  `ibex_pkg.sv` 719–734 (the `lfsr_seed_t` / `lfsr_perm_t` / `ibex_mubi_t`
  clone bounds), `772:20` or `409:13` — inside the named surface.
  `ibex_csr`, `ibex_fetch_fifo`, `ibex_load_store_unit`, `ibex_counter`,
  `ibex_register_file_ff` and `ibex_register_file_fpga` were predicted (the
  prediction is over-broad on purpose) and did NOT move: they list no package.
* **surelog predicted: 15 rows**, of which only `Earlgrey_0_1` (CMP_NOTEQUAL)
  and `ParamOverload2` (CMP_EQUAL) produce a database at all; the other
  thirteen are SLANG_REJECT / SURELOG_FAIL / DEFERRED / NO_DATABASE.
  **surelog measured: 3 rows × 2 modes = 6 / 960** — `ParamOverload2`
  (predicted, class B, dump-difference 4 lines) plus `MiniAmiq` and
  `SeqDriver`, the PROVEN UVM COIN family. Attributed order-blind and then
  proven: the PRISTINE binary run four times on MiniAmiq yields four different
  md5s and four different values at the very cell that "moved"
  (945 / 1217 / 854 / 1371 — a `` `__LINE__ ``-class delta, the documented
  0-or-4-line coin). `Earlgrey_0_1` was predicted and did NOT move.

MOVED-WRONG 0. AWAY-FROM-GOLDEN 0.

## 5. Gates (all green)

* pristine build md5 `75b2098c608dd7ebd50199dd1c27ccbb` — byte-identical to
  the main tree at 7ae0ce08; patched `0c071d12283ce9955fe9c0d53db9363e`.
* `tests/check_goldens.sh`: **23 PASS / 0 FAIL** on the pristine binary AND on
  the patched one; negative control `SLANG_UHDM=/bin/false`: **23 FAIL / 0 PASS**.
* Every sweep exported `SLANG_UHDM` explicitly, and every `cmds.txt` was
  audited BY BINARY PATH: u2r 1742/1742 and 871/871, surelog 1531/1531 (the
  other 50 surelog `cmds.txt` carry no slang line at all — surelog produced no
  database, so slang was never invoked; no other binary appears anywhere).
* **uhdm2rtlil, BOTH modes**: 1742 rows, **0 status diffs and 0 whole-row
  diffs** against `results/golden_uhdm2rtlil.csv` and against my own pristine
  sweep. testflags 742 EQ / 62 NE; default 742 EQ / 62 NE.
* **surelog, BOTH modes**: 1596 rows, **0 status diffs** against
  `results/golden_surelog.csv`, **0 whole-row diffs** against my own pristine
  sweep. default 463 EQ / 20 NE; testflags 459 EQ / 18 NE — the committed
  baseline exactly. (Two rows differ from the *committed* CSV only in the
  workdir path inside a SURELOG_FAIL log line: `LowMemLib`, `LowMemPkg`.)
* `byteverify.sh SELFCHECK=1`: u2r 24/1608 movers (and 12/804 on an
  independent testflags-only workdir), surelog 6/960; selfcheck flags
  1607/1608, 803/804 and 959/960 — the comparator can see.
* canaries: `canaries.sh` ok=52 changed=0 (surelog) and ok=8 changed=0 (u2r);
  `ctcan2.sh` PASS on both; `canaudit.sh` audited=29 UNCOVERED=0 FENCE-BREACH=0.
* protected databases, law vs pristine md5: SVSwitch `4842211c4030` SAME both
  modes, YosysVerx `6ccda350c24a` SAME both modes, InterfaceModPort
  `59a365f3ce2c` SAME both modes, BlackParrotComplex SAME, YosysOldOr SAME,
  Earlgrey_0_1 SAME. Reachability was also checked directly: the scanner finds
  ZERO hits over the whole test tree of SVSwitch, YosysVerx, InterfaceModPort,
  BlackParrotComplex and YosysOldOr.
* `rowheads.sh` over SeqDriver / SimpleUVM / Scoreboard / MiniAmiq /
  BuildUVMPkg / Earlgrey_0_1 / Rggen: identical line for line, pristine and
  patched (SKIP-NOFILE on Scoreboard/tf and Rggen/tf as expected).
* the four slang-fenced names were never dispatched (canaudit fence check).

## 6. Residues, ranked — START HERE

* **R1′ — the FOLDED bound of a SCALAR package parameter's inline packed
  range.** `parameter logic [MSB:0] AddrOne`: in every reduced view golden's
  bound is the referenced parameter's OWN value constant (vpiSize = that
  parameter's declared width, plus a `ref_typespec` onto its typespec) and we
  emit a bare 64-bit re-render. This is § pkgParamUnpackedElemFoldConst one
  level over, on `makeTypespec`'s scalar fold branch — a MUCH wider surface
  (every non-tf `logic_typespec` bound in every context), which is why this
  pass stopped at the array-element arm. Witness `grid/gF` (head at the
  `AddrOne` line) and `g1` (head at `8:20`). NOT on any ibex row's path any
  more.
* **R3 — `` `PRIM_STRINGIFY `` keeps the continuation-line indent (now ELEVEN
  u2r rows, up from three).** `prim_assert.sv:21`
  `` `define PRIM_STRINGIFY(__x) `"__x`" ``, reached from `ASSERT_ERROR`'s
  `$error(…)` whose last argument sits on a continuation line indented by nine
  spaces. Golden `"IbexRegImmAluOpKnown"` (vpiSize 160); ours
  `"         IbexRegImmAluOpKnown"` (vpiSize 232). After this pass it is the
  head on branch_predict, compressed_decoder, decoder, multdiv_fast,
  multdiv_slow, pmp, wb_stage, csr, fetch_fifo, load_store_unit — and
  `ibex_pmp`'s is at `34:10`, one line further on. **This is now the widest
  single head in the u2r corpus.** Scope warning unchanged from r11u5: the
  stringification happens in slang's PREPROCESSOR and patching slang is out of
  scope, so it must be normalised exporter-side (our constant's span is the
  giveaway — `line:33:10, endln:23:23`, an end BEFORE its start, i.e. a
  macro-expansion range) or ranked unreachable.
* **R4 — `ibex_alu`'s assignment-pattern grouping.** `ibex_pkg.sv:750`
  `parameter pmp_cfg_t PmpCfgRst[PMP_MAX_REGIONS] = '{…}`: golden's operand[0]
  is a nested `operation` (a per-element `tagged_pattern` group), ours is a
  flat `constant`. 4534 cmp lines — a vector-size mismatch printing the whole
  golden vector, so the count is not a distance. One row.
* **R5 — `ibex_icache` at `17:44`** and **R6 — `ibex_tracer` at
  `ibex_tracer_pkg.sv:305:87`** (`ref_obj (ibex_tracer_pkg::OPCODE_C0)`): one
  row each, uncharacterized.

## 7. Instruments

* `tsedge.cpp` — THE instrument. Per design listing (AllPackages / TopPackages
  / AllModules / TopModules) and per parameter: the pointer-interned identity
  of the `Actual_typespec`, of its `Typedef_alias` target and of its
  `Instance()`, plus the fold shape of each of its own ranges' left bound and,
  for a `$clog2` inside one, the shape of the call's ARGUMENT. It recurses
  `Elem_typespec`, so an unpacked-array parameter's element range is visible
  too. Identity comes from the OBJECT POINTER, never from dump order — the two
  elaborated copies are text-identical apart from the fold and cannot be told
  apart any other way. Build:
  ```
  g++ -std=c++20 -O1 tsedge.cpp -o /tmp/r11u6_tsedge -I$HOME/.local/include \
      $HOME/.local/lib64/libuhdm.a $HOME/.local/lib64/libcapnp.a \
      $HOME/.local/lib64/libkj.a -lpthread
  ```
* `grid.sh <pristine-bin> <law-bin> [arm…]` — runs the grid, records every rc.
* `heads.sh <sweep-workdir>/<mode> [name…]` — one head per row, read from the
  databases the SWEEP already built, so what is scored is what the judge
  scored.
* `predict.py u2r|surelog` — the a-priori mover prediction (§ 4).
* `canaries.sh`, `ctcan2.sh`, `canaudit.sh`, `byteverify.sh`, `ct8rows.sh`,
  `rowheads.sh` — the r10uvm221 battery, copied unmodified.
