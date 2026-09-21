# r11v77 — the adversarial verification of r11u77, and the one law it added:
# the unpacked wrapper is the SCALAR holder wrapped, and we write only the
# scalar holders we measured

Base commit `7d0c7bf4`. This directory is the VERIFIER's half of pass 77.
The implementer's decode, grid and census live one directory over
(`tools/probe/r11u77repro/`); everything here was measured independently, in
the verifier's own worktrees, with the verifier's own binaries.

## 0. What reproduced, bit for bit

Built both binaries from source (`-j 2`, md5 taken separately, both frozen
`chmod 555` before any sweep):

```
pristine  963667a2299a360105d9677e3a065959   == the main tree @7d0c7bf4 == the OPS pin
patched   c676e58722bcd4bba191cfec84ab6799   == the implementer's reported md5
verified  2992f10420cb3fad000a88fe7b3fbe76   == patched + § caImportedPkgHoistUnpackedIsWrappedScalar77
```

Reproduced from the implementer's report, number for number, on the 23 arms
of `r11u77repro/grid`:

* every arm `golden_rc=0 ours_rc=0`; `y6_hoistconv` `cmp_rc 255 -> 0`
  (ONE conversion) and every arm that was `cmp_rc 0` at the base still 0;
* the whole `gold_only/ours_only` distance table (`g2` 209/4 -> 137/4,
  `xe` 256/59 -> 187/12, `y1` 893/7 -> 462/12, `y2` 373/177 -> 297/44,
  `y3` 859/28 -> 433/28, `y4` 578/55 -> 344/11, `y5` 971/146 -> 555/33,
  `y6` 42/9 -> 41/5);
* the switch ledger: `R11U77_OFF=1` is **0 differing lines from the pristine
  database on all 23 arms**, and each single switch returns exactly its own
  arms (`PKGNET_OFF` y1/y3/g2 to 0, y4 296->128, y5 545->193;
  `HOISTKIND_OFF` y3/g2 to 0, xe 128->1, y2 311->4; `DEFNT_OFF` y6 to 0 and
  y1/y3/y4/xe to the patched reading);
* the census: uhdm2rtlil 9480 cell rows with **0** `R11U77DEFNT` and **0**
  `R11U77HOIST`; surelog 41398 rows with **410 DEFNT (MOVED 0, net=1 on 0)**
  and **278 HOIST (kind=0 on 278)**, over exactly the eleven (test, mode)
  pairs the implementer names.

## 1. The break grid: nine new arms, every one a real Surelog v1.87 golden

`grid/` — `va_netstructkinds`, `vb_unpackedfaces`, `vc_netkw`,
`vd_structmem`, `ve_ifacenet`, `vf_collide`, `vg_constauto`, `vh_arrelem`,
`vi_defnt`. All nine `golden_rc=0 ours_rc=0` on both binaries.

**Faces the implementer's table got RIGHT, confirmed against golden here:**

| face | golden | patched |
|---|---|---|
| `wire si_t` (net-declared struct, an `int` member) | `struct_var` | ours |
| `wire un_t` (net-declared packed union) | `logic_net` | ours |
| `un_t` (variable packed union) | `union_var` | ours |
| a struct with an ENUM / `bit` / packed-array-of-STRUCT member | `struct_var` | ours |
| a struct with a SIGNED logic / packed-array-of-logic member | `struct_net` | ours |
| `uwire` / `tri1` / `triand` / `trior` / `wire signed` package nets | `logic_net` nt=1/… | ours |
| a `const` / `var` / plain / `wire` struct package variable | `struct_net` | ours |
| a package net + unpacked array + struct imported into an INTERFACE | golden's | ours |
| a hoisted name COLLIDING with a module-own declaration | unchanged | unchanged |
| 14 of 15 def-view `vpiNetType` spellings (`vi_defnt`) | golden's | ours |

**And the object-level regression scan is clean.** For every one of the 32
arms (23 implementer + 9 verifier) x 6 dump sections, every top-level object
block was normalised for spans and diffed golden-vs-ours on BOTH binaries:
**0 blocks that matched golden on the pristine binary differ on the patched
one, and 0 on the verified one** (`shapecmp77v.py`). Nothing
pristine-right becomes patched-wrong anywhere in this grid.

## 2. WHAT BROKE: the unpacked wrapper, five element spellings out of ten

`vh_arrelem` asks golden for every element kind an unpacked package array can
have, net-declared and variable-declared side by side, and `vb_unpackedfaces`
asks for the dimension spellings. Read as *kind / vpiAutomatic / the
`vpiReg`|`vpiNet` element's own kind* — and every one of those three is a
COMPARED field (`variables::Compare` reads `VpiAutomatic`;
`array_var::Compare` reads `Variables()`; `expr::Compare` reads `VpiSize`):

```
           GOLDEN                        r11u77 AS SUBMITTED
a_nlog     array_net auto=0 logic_net    array_net auto=0 logic_net     ok
a_vlog     array_var auto=1 logic_var    array_var auto=1 logic_var     ok
a_nsl      array_net auto=0 struct_net   array_net auto=0 struct_net    ok
a_vsl      array_net auto=0 struct_net   array_net auto=0 struct_net    ok
a_nun      array_net auto=0 logic_net    array_net auto=0 logic_net     ok
a_nsi      array_var auto=0 struct_var   array_net auto=0 struct_net    WRONG
a_vsi      array_var auto=0 struct_var   array_var auto=1 logic_var     WRONG
a_vun      array_var auto=0 union_var    array_var auto=1 logic_var     WRONG
a_nen      array_var auto=0 enum_var     array_net auto=0 logic_net     WRONG
a_ven      array_var auto=0 enum_var     array_var auto=1 logic_var     WRONG
u_2d       array_var vpiSize SIX         array_var vpiSize TWO          WRONG
u_td       array_var no size/range/elem  array_var size 2, logic_var    WRONG
```

`hoistKind77` tested `isNetDecl77` BEFORE the element's typespec, where the
SCALAR road tests the struct first — so a `wire si_t a[0:1]` became an
`array_net` although golden's holder is an `array_var`, and the ArrayVar
builder stamped `VpiAutomatic(true)` unconditionally and always wrote a
`logic_var` element. Golden's rule, read off the ten rows, is simply **the
scalar holder wrapped**: the element's own typespec decides net-or-variable
exactly as it does for the scalar spelling (all-logic struct -> net, any other
struct -> var, enum -> var, union -> the declaration), `vpiAutomatic` is
stamped only on the plain-integral variable, and the element object is the
element type's own kind.

None of the twelve is a REGRESSION — pristine listed no elaborated holder at
all for any of them — and the census says the corpora contain **zero** hoisted
unpacked-array entries, so nothing in either corpus moves either way. But each
is an object we would newly mint whose compared fields are not golden's, which
is the same class the OPS rule names: *golden writes nothing on a miss; never
invent a holder golden lacks.*

## 3. THE FIX (§ caImportedPkgHoistUnpackedIsWrappedScalar77)

Minimal and inside LAW B's own gate (`R11U77_HOISTKIND_OFF=1` still drops it
whole). `hoistKind77`'s unpacked branch now reads the ELEMENT's own typespec
first and returns a new `HoistKind77::ArraySkip` for every shape this builder
does not write golden's object for:

* a SECOND unpacked dimension (golden's `vpiSize` is the flattened count);
* a TYPEDEF'd unpacked array, which has no declarator dimension and whose
  golden holder is empty;
* a packed-struct element that is not all-logic, an ENUM element, and a
  packed-UNION element on a VARIABLE declaration.

`ArraySkip` is handled in `emitInstance`'s hoist loop by an explicit
`continue` — the entry is never handed to the pre-77 road either, so the
ELABORATED listing is byte-for-byte pristine's for it. **The DEF-VIEW entry
is untouched and stays on LAW A's listing, where golden agrees with all ten
element spellings and all four dimension spellings** (`vh_arrelem` /
`vb_unpackedfaces`, `uhdmallModules`, 10 of 10 and 8 of 8).

Measured effect of the fix, arm by arm: **only `vb_unpackedfaces` and
`vh_arrelem` change at all** (every other one of the 32 arms is byte-identical
between the patched and verified binaries, dump-tag normalised), and on those
two the `ours_only` distance FALLS (46 -> 25 and 78 -> 52) while the five
wrong holders disappear and the five right ones stay.

## 4. Gates on the VERIFIED binary — all green

```
build         pristine 963667a2299a360105d9677e3a065959 (== main tree @7d0c7bf4)
              verified 2992f10420cb3fad000a88fe7b3fbe76
goldens       verified PASS 23 FAIL 0; pristine PASS 23 FAIL 0; /bin/false PASS 0 FAIL 23
u2r           788/16/67 on both modes, both binaries = the committed baseline
              vs results/gate_uhdm2rtlil.csv         PASS every row byte-identical
              vs results/golden_uhdm2rtlil.csv       0 of 1742 rows differing
              byteverify SELFCHECK=1 vs own pristine MOVERS 0 / 1608 (selfcheck 1607/1608)
surelog       default 474/9, testflags 469/8 on BOTH binaries, every other status
              bucket identical (5 DEFERRED, 285/286 SLANG_REJECT, 25/23 SURELOG_FAIL,
              3 NO_DATABASE, 1 NO_UHDM, 1 TIMEOUT, 2 UNTRANSLATABLE)
              whole-row join vs results/golden_surelog.csv: 3 of 1596 rows, ALL
              environment and ALL present on the pristine sweep too (the
              Earlgrey_0_1 dump-COLUMN draw, two LowMem* workdir strings)
              byteverify SELFCHECK=1 vs own pristine MOVERS 6 / 960 (selfcheck 959/960)
canaries      SVSwitch 4842211c4030, YosysVerx 6ccda350c24a, InterfaceModPort
              59a365f3ce2c, YosysOldOr d68e0796d62c, BlackParrotComplex
              e3e354129d5a/73a10e8217e5, Earlgrey_0_1 8bdf25272e08/59d0ee6d10c3
              — ALL SAME as pristine and all equal to the OPS pins
              canaries.sh u2r ok=8 changed=0; surelog vs committed ok=51 changed=1
              (Earlgrey_0_1/default, the dump-column draw); ctcan2 PASS both corpora
              canaudit.sh audited=29 UNCOVERED=0 FENCE-BREACH=0
rowheads      measured=12, 11 of them `0 0 cmp rc=0`; Rggen/default 64 1 rc=255
              (its committed CMP_NOTEQUAL row, unchanged); SKIP-NOFILE 2, UNKNOWN 0
binary audit  u2r 1742/1742 per workdir, surelog 1531/1581, other-tree binaries 0
fences        the four slang-fenced names: 0 in the production diff, 0 files here
results/*.csv untouched
```

**THE SIX SURELOG MOVERS, ATTRIBUTED ONE BY ONE** by a path-normalised,
id-stripped, ORDER-BLIND whole-dump diff. Five are exactly four lines, and
every one of those four is a `UINT:<n>` / `vpiDecompile:<n>` pair — the
documented UVM macro-buffer line-number class — and the sixth is the
documented ZERO-line order draw:

```
default/MiniAmiq      4 lines   UINT/vpiDecompile 589  <-> 756
default/SeqDriver     4 lines   UINT/vpiDecompile 0    <-> 1224
default/SimpleUVM     4 lines   UINT/vpiDecompile 1431 <-> 547
default/Scoreboard    0 lines   (the order draw — order-blind identical)
testflags/MiniAmiq    4 lines   UINT/vpiDecompile 566  <-> 743
testflags/SeqDriver   4 lines   UINT/vpiDecompile 1259 <-> 999
```

Not one `vpiNetType`, not one listing line, not one hoisted object among
them. `BuildUVMPkg`, `MiniAmiq`, `SeqDriver`, `SimpleUVM` stay `CMP_EQUAL` in
both modes and `Scoreboard` stays `CMP_EQUAL`/`SLANG_REJECT`, on the committed
baseline, on the pristine binary and on the verified one. `ApbSlave` and
`PackageNet` carry hoisted entries and are not movers at all.

**MOVED-WRONG 0 / AWAY-GOLDEN 0**, both corpora, both mode columns.

## 5. Residues this verification found (ranked, none of them a regression)

1. **The five unpacked-array element spellings and the two dimension
   spellings above now have NO elaborated holder** where golden has one
   (`array_var` with a `struct_var`/`enum_var`/`union_var` element, the
   flattened `vpiSize`, the empty typedef'd holder). Writing them is one
   builder away: `makeHoistHolder77`'s ArrayVar arm has to mint the ELEMENT's
   own kind instead of a `logic_var`, stamp `vpiAutomatic` only for the plain
   integral, and compute the flattened size. The golden table is measured and
   committed here (`grid/vh_arrelem`, `grid/vb_unpackedfaces`).
2. **`var logic [7:0]` keeps the over-broad def-view `vpiNetType:36`**
   (`grid/vi_defnt` `d_varlog`; golden stamps none). This is NOT this pass's
   doing — pristine stamps 36 too, and LAW C changes nothing for it — but it
   is the one spelling of fifteen where § caImportedPkgDefNetType77's rule as
   stated ("the written base keyword through one typedef hop") and golden part
   company: a `var`-qualified declaration is not a net type whatever its base
   keyword.
3. **A gen-scope namesake whose name COLLIDES with a module-own declaration
   binds the MODULE's object where golden binds the hoisted package copy**
   (`grid/vf_collide`, all three rows, both binaries). Both objects carry the
   same compared fields (`logic_net work@dut.c_net`), so the judge is silent
   here — the difference is visible only in the span — but the BINDING is to
   the wrong object and a future shape change would expose it.
4. The implementer's R0 stands and is confirmed by every arm here: the
   PACKAGE's own listing (`emitPackage`, `src/ParamEmit.cpp`) still lists no
   package net and no unpacked-array package variable and stamps the same
   over-broad def net type, and it is the single head masking `va`, `vb`,
   `vc`, `vd`, `ve`, `vg`, `vh` and `vi` here exactly as it masks `y1`-`y5`
   and `xe` there.

## 6. How to re-run

```bash
GRID=<this dir>/grid bash rr77.sh <binary> <tag>          # every arm, both rc values recorded
python3 shapecmp77v.py <gold.dump> <ours.dump> [section]  # the object-block comparator (span-normalised)
#   run it on the PRISTINE pair and the PATCHED pair and diff the two name
#   lists: a name that appears only in the patched list is a MOVED-WRONG.
```

The instruments the implementer's dir carries (`lister77.py`, `calist77.py`,
`score77.py`, `sw77.sh`, `cellcen77.py`, `byteverify.sh`, `ct8rows.sh`) were
used verbatim from `tools/probe/r11u77repro/` and are not duplicated here.
No corpus test is dispatched from this directory; every arm is its own
`dut.sv`, and the four slang-fenced names appear in no file here but
`canaudit.sh`'s own `FENCED=` line.
