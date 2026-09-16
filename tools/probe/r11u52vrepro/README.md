# r11u52v — adversarial verification of ROAD C (`bodyTypedefElemBoundSymbolic52`)

Base `4e421b38` (matrix-1.87). Pins per `SUPPORT_MATRIX.md`: slang upstream
`7d61e0ad1`, UHDM v1.87, Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`,
the golden producer), uhdm2rtlil v0.68.

Three binaries, each built here from its own worktree and frozen `555` before
any sweep:

| binary | md5 | what it is |
|---|---|---|
| pristine | `9be297f87ce752ca318a4d32b204ebe9` | `4e421b38`, **byte-identical to the main tree's binary** |
| law | `b83456d497931cf6aec70c2918efc63d` | the implementer's patch, unmodified |
| verified | `7ad7754335b99b206c84ce70148edec3` | the law + the one fix in §3 |

Every `cmds.txt` in every sweep was audited by binary PATH: 3323 files per
sweep root, 3273 carrying a `slang:` line, **one binary each**, never the main
tree's.

## 1. Every headline number reproduced

| claim | reproduced | how |
|---|---|---|
| head at base, both modes: `CMP_NOTEQUAL`, 1 head / 28 cmp lines | **YES, bit-for-bit** | `uhdm-cmp golden.uhdm` vs our db; the LHS/RHS blocks match `r11u52repro/evidence/HEAD.base.txt` character for character |
| producer decode | **YES** | `CompileModule.cpp:653` (module body) and `:1130` (interface body) hard-code `Reduce::No`, against `m_instance ? Reduce::Yes : Reduce::No` at `:726/:742/:748/:762/:768`; `CompileHelper.cpp:2278` forwards it to `compileTypeDef`, `:1060` to the element `compileTypespec` under `array_tps` |
| arm score TOWARD 18 / AWAY 0 / STILL 65 | **YES, exactly** | the pass's seven arms re-run on my own three binaries with `score52.sh` |
| u2r byte census MOVERS 2 / 1608 | **YES, the same two paths** | `byteverify.sh`; positive control `SELFCHECK=1` = 1607 / 1608 |
| surelog byte census: only the UVM nondeterminism class | **YES — but 5 movers, not 4** | see §2 |
| residue 120 / 35 → 27 / 6 on the head row | **YES, exactly** | order-insensitive whole-dump diff, id- and path-normalised |
| head advances to `logic_net (work@dut.mem)`, row stays `CMP_NOTEQUAL` | **YES, both modes** | ADVANCE, not CONVERT — as the brief predicted |
| the two V3 fences byte-unchanged | **YES** | `c2_typedef_pkg` and `vc1_typedef_shapes` dumps are 0 diff lines base-vs-law and base-vs-verified after path normalisation |
| construct census: exactly ONE discovered row | **YES, independently** | my own regex scan finds the trigger shape in 6 files; five are `cva6_equiv`'s hpdcache, which is **not a discovered row** (`cva6_struct_param_field` is the only cva6 row in either CSV) |

Gates on the law binary, all green and all re-run here: goldens 23 PASS / 0
FAIL with `SLANG_UHDM=/bin/false` giving 0 / 23; uhdm2rtlil **0 rows** differ
from `results/golden_uhdm2rtlil.csv` in either mode; surelog differs on
`LowMemLib` / `LowMemPkg` testflags only, whose `SURELOG_FAIL` detail string
embeds the workdir path. Histograms are the base exactly: **474/9 + 469/8
surelog, 783/21/67 uhdm2rtlil both modes.** Canaries `ok=52 changed=0` and
`ok=8 changed=0`; both `ctcan2` PASS; `canaudit` audited=29 UNCOVERED=0
FENCE-BREACH=0. Byte pins all SAME at their pinned values: SVSwitch
`4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`,
Earlgrey_0_1 default `8bdf25272e08` / testflags `59d0ee6d10c3`,
BlackParrotComplex and YosysOldOr. `rowheads.sh`: SeqDriver, SimpleUVM,
Scoreboard, MiniAmiq, BuildUVMPkg and Earlgrey_0_1 all `cmp rc=0 / 0 heads` in
both modes. `results/*.csv` read, never written. The fenced tests were never
dispatched.

## 2. The surelog census is FIVE movers, not four — and all five are the coin

The pass reports 4; I measure **5 / 960**: MiniAmiq ×2, SeqDriver ×2,
SimpleUVM ×1. Every one attributed two ways, not asserted:

* **Order-blind whole-dump diff** (sorted, id- and path-normalised): each of
  the five is exactly **4 lines**, a `UINT:` / `vpiDecompile:` pair on each
  side — the documented macro-buffer line-number class. No typespec, no range,
  no bound.
* **Positive control**: the SAME pristine binary run three times over
  MiniAmiq / SeqDriver / SimpleUVM in default mode gives MiniAmiq three
  DIFFERENT databases (`16f266c4452b`, `2b7707b73353`, `fb2dcf006e9e`), SeqDriver
  two and SimpleUVM two — and the law binary's SimpleUVM hash `d4f8cd018f2d`
  is one the PRISTINE binary itself produced. All CMP_EQUAL throughout.

So the count is a draw, not a delta: 4 and 5 are the same reading. The
MOVER-RULE family's statuses do not move.

## 3. ONE DEFECT FOUND AND FIXED — the truncated operation clone

`copyRangeVec`'s `cpOp` models three UHDM kinds (constant, ref_obj, operation)
and, for an operation, **silently dropped any operand it could not model**:

```
for (auto* x0 : *ops0)
    if (auto* x = cpOp(x0, p))      // nullptr -> the operand vanishes
        ops->push_back(x);
```

The result is a **binary operation carrying ONE operand** — a malformed
expression the pristine binary never emits. Measured, not argued: arm
`grid/b11_operands` puts a fourth kind under the bound's operation and
`opscan.py` counts the malformation directly.

| bound | operand kind the cloner cannot model | pristine | law | verified |
|---|---|---|---|---|
| `[$clog2(N)-1:0]` | `sys_func_call` | 0 | **2 truncated copies** | 0 |
| `[$bits(int)-1:0]` | `sys_func_call` | 0 | **2** | 0 |
| `[q::f(N)-1:0]` (package constant function) | `func_call` | 0 | **2** | 0 |
| `[ARR[0]-1:0]` (localparam bit-select) | `bit_select` | 0 | **2** | 0 |

`opscan.py` over all eleven arms: pristine **0** truncations everywhere, law
**5** (4 in `b11_operands`, 1 in `b2_exprforms`), verified **0** everywhere.

**The fix** ([src/TypeEmit.cpp:14212](src/TypeEmit.cpp#L14212), read at
[src/TypeEmit.cpp:14284](src/TypeEmit.cpp#L14284)): a `cpAble` predicate asks
whether the WHOLE bound tree is modelled BEFORE anything is minted; when it is
not, the bound is SHARED, which is exactly the pre-law behaviour for that copy
and is invisible to the judge (no generated `Compare` reads object identity or
`VpiFullName`). Asking before minting also matters because abandoning a
half-built clone would leave orphan objects in the serializer's table.

**The fix is byte-free on the corpus**: `byteverify.sh` between the verified
and the law workdirs over uhdm2rtlil is **MOVERS 0 / 1608**, and the two movers
against pristine keep the law's exact hashes (`41cd452aebaa`, `ac8d544f78b8`).
Over the eleven arms it changes only the two that carry an un-modellable
operand (88 and 22 dump lines); the other nine are byte-identical to the law
build.

## 4. Breaking the law: eleven arms, faces the pass did not cut

`grid/` holds one design per arm. Driver: `runv.sh <binary> <tag>` (it reuses
`../r11u52repro/run52.sh`, `cell52.py`, `score52.sh`, so only the DESIGNS are
new). Both rcs recorded per arm; **every arm compiles rc 0 on both sides** in
all three builds.

Score against the base, verified binary: **TOWARD 59, AWAY 0, STILL 74** over
the eleven arms (law binary: TOWARD 52, AWAY 0 — the one-cell difference is
`b2`'s `$clog2` copies, which the fix SHARES instead of truncating).

| arm | the face | verdict |
|---|---|---|
| `b1_structelem` | a struct with an **unpacked-array member** as the typedef's element | the flag LEAKS into `buildStructTs` — see §5 |
| `b2_exprforms` | 11 bound forms: whitespace, parens, `N*2-1`, `$clog2`, `4'd7`, `'h5`, bare `N`, both-bounds, ternary, literal | sized/hex literals UNCHANGED and still agree with golden; every symbolic form matches golden after the law |
| `b3_namedelem` | a NAMED element carrying a packed dim (`vec_t [N-1:0] t [D]`) — the `mkP` route, not `anonAggregateElemTs` | untouched, correctly: **golden FOLDS that cell too** |
| `b4_program` | a PROGRAM-body typedef | the flag reaches it and is RIGHT: `CompileProgram.cpp:301` also hands a hard `Reduce::No`; the arm's head advances to the net-type residue |
| `b5_localparam` | parameter / localparam / wildcard-imported / `pkg::`-scoped bounds | parameter and localparam now match golden **exactly**; the two package forms are a new residue (§6 R-a) |
| `b6_macro` | whole dimension, bound, and mixed macro expansions | the law FIXES all of them — spans and values now match golden cell for cell |
| `b7_pkgbound` | a SUBMODULE body typedef at two instances, with a function-local holder | fires, names right (`1×N + n×mem_t.N`); residual disagreement is only the copy-count residue |
| `b8_multiinst` | an INTERFACE at three different overrides plus three module instances | fires in every copy, names right |
| `b9_pkgstruct` | a PACKAGE struct with an unpacked-array member as the element | leak reaches it; golden keeps it symbolic too, so TOWARD |
| `b10_class` | a CLASS typedef with an unpacked dim beside the module-body twin | **the class arm STAYS**: the only dump lines that move are line 20, the module-body typedef; the class typedefs and the arm's head are identical |
| `b11_operands` | `$clog2`, `$bits`, a package constant function, a localparam bit-select | the defect of §3 |

Two hazards I expected and DISPROVED by measurement:

* **Cross-typedef mis-scoping.** `elemSymBoundTs52` is keyed by object
  identity, and `c1`'s `up1_t` demonstrably SHARES `pk1_t`'s element object
  (residue R5). If that shared object were ever recorded, `pk1_t`'s copies
  would be re-scoped `up1_t.NDATA`. It is not: the shared route finds its ts in
  `typedefTs` and never calls `anonAggregateElemTs`, so `pk1_t`'s cells at
  `14:18-14:25` are byte-identical before and after.
* **A sized or hex literal bound taking the symbolic path.** The law's numeric
  test scans the raw text for non-digits, so `4'd7` and `'h5` ARE routed to
  `emitSyntaxExpr`; they come back as constants that still agree with golden
  cell for cell, and being constants they are never recorded in the identity
  set.

## 5. The leak the pass did not declare (measured, benign, TOWARD)

The flag is set around `buildUnpackedArrayTypedefTs`, but that function calls
`buildStructTs` for a struct element, and `buildStructTs` mints its own
unpacked-array member element typespecs through the very
`anonAggregateElemTs` the law re-routes
([src/TypeEmit.cpp:12485](src/TypeEmit.cpp#L12485) and
[src/TypeEmit.cpp:13242](src/TypeEmit.cpp#L13242)). So a body typedef whose
element is a struct **with an unpacked-array member** changes that member's
bounds too.

The pass's `c1` and `vc1` arms could not see it: their structs are PACKED with
scalar members, and `anonAggregateElemTs` returns null for struct and enum
elements, so those cells genuinely do not move. `b1` and `b9` cut the missing
face.

Direction measured, both arms: **TOWARD**. Golden keeps those member bounds
symbolic (`b1` `1xSYM(work@dut.st_t.pair.N) 1xSYM(st_t.pair.N)` vs our base
`2xFOLD(N-1)`; `b9` the same for a PACKAGE struct), and the leak converts one
copy of each. No AWAY cell in either arm. It is scope the README understates,
not a regression — but the README's "struct member bound … unchanged — control"
line should read "unchanged for a struct with no unpacked-array member".

## 6. Residues this verification adds (ranked)

* **R-a — a bound naming a PACKAGE parameter now diverges in KIND, not value.**
  Golden SUBSTITUTES an imported or `pkg::`-scoped parameter in the element
  bound (`[PW-1:0]` → `operation(constant 6, constant 1)`); after the law we
  emit `operation(ref_obj PW, constant 1)`. Both disagreed at base too (we had
  one folded constant), and the operation SHAPE now matches where it did not
  before, so the law is closer — but the operand kind is a new, different
  disagreement. Arms `b5` (`t_imp`, `t_scoped`) and `b11` (`t_scp`,
  `$bits(int)`). No corpus row carries it. It wants its own grid: the
  discriminator is almost certainly whether the name resolves OUTSIDE the
  compiled body.
* **R-b — the leak of §5** is undeclared scope; harmless today, but any future
  arm where golden FOLDS a struct member bound under a body typedef would turn
  it into an AWAY. Fence it with an arm before the next pass touches
  `buildStructTs`.
* **R-c — `b3`'s named-element route is a separate, untouched fold.**
  `typedef vec_t [N-1:0] t [D]` goes through the `mkP` constants inside
  `buildUnpackedArrayTypedefTs`, never `anonAggregateElemTs`. Golden FOLDS that
  cell as we do, so nothing is owed — but the arm's head, once the law closes
  the inline fold, is the PRE-EXISTING kind mismatch golden `logic_typespec`
  (with an `Elem_typespec`) versus our `packed_array_typespec`, which is worth
  its own pass.
* **R-d — a class property whose type is an unpacked-array typedef is an
  UNTRANSLATABLE** (`class property type: FixedSizeUnpackedArrayType`, rc 4).
  Pre-existing, unrelated to the law, and it is why `b10` declares the class
  typedefs without properties of that type.
* The pass's own R0–R5 all reproduce: R0 (`vpiNetType:36` missing on a net
  declared with an unpacked-array typedef — the site is
  [src/EmitHelpers.h:970](src/EmitHelpers.h#L970) `netTypeFor`), R1 (the
  doubled `work@dut.mem.mem.i` hier-path segments), R2 (one extra golden copy
  of the array's own `[DEPTH]` bound), R3 (a function / task / named-begin body
  typedef absent from our database, beside the generate-block and package
  holes), R4, R5. The 27 golden-only and 6 ours-only residue lines on the head
  row are exactly R0 + R1 + R2 plus the dump's own header line.

## 7. Reproducing

```bash
B=/tmp/v11u52_bin
bash runv.sh $B/pris.bin base          # all 11 arms, both rcs recorded
bash runv.sh $B/fix.bin  fix
GRID=$PWD/grid BASE=base LAW=fix bash ../r11u52repro/score52.sh
python3 opscan.py grid/b11_operands/ours.base.dump grid/b11_operands/ours.fix.dump
```

`opscan.py` is the truncation instrument: it reports every operation whose
operand count differs between copies at the same source span, and every
binary-opType operation carrying one operand. Its own control is the pristine
dump, where both counts are 0.
