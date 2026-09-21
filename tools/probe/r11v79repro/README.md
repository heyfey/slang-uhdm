# r11v79 — ADVERSARIAL VERIFICATION OF r11u79 (the package's own listing)

Base `15ff66f6`. Pristine binary `c56e3f2c141ee7e9a6bb41c9d4e38f8c` — built in
this verifier's OWN worktree, `-j 2`, md5 taken separately, and byte-identical
to the main tree at `15ff66f6` and to the OPS pin, compared not assumed.
r11u79 as submitted rebuilt to `67a6075c5d761d74bd4a28b0d0cf0b6b` — the
implementer's md5, reproduced independently. VERIFIED binary
`ba0ff704de4ab0b0d23c7bde1be56d97`. All three frozen `chmod 555` before any sweep.

## VERDICT: ACCEPT WITH FIX. Ship `/tmp/r11u79.verified.patch`.

r11u79 as submitted is right on all 38 of its own arms and 0/1742 + 0/1596
corpus rows, but it is WRONG on eight package-listing cells of legal SV that
the PRISTINE binary gets RIGHT. Two faces, both in LAW B, both unmeasured by
the submitted grid. Fixed here, re-gated in full.

### FIX 1 — the struct member test must NOT recurse

`pkgStructAllLogic79` recursed into a nested struct member and failed the
holder when the NESTED struct carried an `int`. `elabSignal` tests the
member's OWN TYPESPEC KIND: a struct member compiles to a `struct_typespec`,
one of the two kinds the arm accepts, and the walk stops there. Golden,
five instances, both package views, all `logic_net`:

```
    arm/cell                     GOLDEN      r11u79        pristine
!!  q1_structmem m_nestint       logic_net   struct_var    logic_net  <- right
!!  q8_hopviews  k_n2            logic_net   struct_var    logic_net  <- right
!!  q8_hopviews  k_n3            logic_net   struct_var    logic_net  <- right
    q8_hopviews  k_n4            logic_net   struct_var    (absent)
    q1_structmem m_nest          logic_net   logic_net     logic_net
```

The other eight member faces r11u79 never spelled all agree with golden both
before and after: a packed UNION member, a packed-array-of-struct member, a
`reg` member, a SIGNED logic member, an UNPACKED-array member, a `bit`
member, a single-member struct (`q1_structmem`, nine spellings).

### FIX 2 — the typespec override is PER VIEW; the def view resolves ONE hop

r11u79 read one kind table for both package views. Golden's two views
DISAGREE on every typedef chain of length two or more: the def view carries
`compileTypespec`'s reading of the type AS WRITTEN — one hop — so a longer
chain presents an alias typespec the arm chain has no case for and the
DECLARATION's net answer stands, while the elaborated view is fully resolved.

MEASURED, arm `q8_hopviews`, one real Surelog v1.87 golden, every override
kind at one, two and three hops, BOTH package sections scored:

```
  spelling                      DEF (uhdmallPackages)  ELAB (uhdmtopPackages)
  typedef bit     -> b1_t x     bit_var                bit_var
  typedef b1_t    -> b2_t x     logic_net              bit_var
  typedef b2_t    -> b3_t x     logic_net              bit_var
  typedef enum    -> e1_t x     enum_var               enum_var
  typedef e1_t    -> e2_t x     logic_net              enum_var
  typedef struct(int) -> s1_t x struct_var             struct_var
  typedef s1_t    -> s2_t x     logic_net              struct_var
  typedef byte    -> y1_t x     byte_var               byte_var
  typedef y1_t    -> y2_t x     logic_net              byte_var
  typedef real    -> r1_t x     real_var               real_var
  typedef r1_t    -> r2_t x     logic_net              real_var
  typedef struct(unpacked,byte) -> u1_t x  struct_var  struct_var
  typedef u1_t    -> u2_t x     logic_net              struct_var
  an ALL-LOGIC struct at ANY chain length stays logic_net in both views
```

The rule only ever moves an entry TOWARD the net vector, so it never mints an
object golden lacks — the 73/74/77 break class does not apply. r11u79's
`z3_pkgtdnet` measured only ONE-hop spellings, where the two views agree,
which is why the face was invisible to it.

Both fixes ride LAW B's existing switch: `R11U79_OFF=1` reproduces the
pristine database BYTE FOR BYTE on all eight verifier arms, the two the fix
touches included (`sw79.sh`, `vs_pristine=0` on every arm).

### The cosmetic nit, corrected

r11u79 asked the integrator to squash `if (A && B(...)) return; return;` to
"a plain call followed by one return". That would DROP the guard and run the
array builder on the importing module's hoisted copy — ground this law was
never measured on. Squashed to `if (A) B(...); return;` instead.

## 1. EVERY HEADLINE NUMBER REPRODUCED BIT FOR BIT

| claim | r11u79 | reproduced here |
|---|---|---|
| pristine md5 | `c56e3f2c...e38f8c` | SAME, == main tree @15ff66f6 == OPS pin |
| patched md5 | `67a6075c...0b6b` | SAME (built independently) |
| the seven witness heads | `heads=1`, head = `package: <name>` | SAME, all seven |
| grid | 38 arms, 8 CONVERT, 0 REGRESS | SAME, same eight names |
| goldens | 23/0 patched, 23/0 pristine, 0/23 `/bin/false` | SAME |
| u2r | 788/16/67 x4 | SAME x6 (three binaries x two modes) |
| u2r byteverify | MOVERS 0/1608, selfcheck 1607/1608 | SAME |
| surelog | 474/9 + 469/8 both binaries | SAME on all three binaries |
| surelog census | 1778 rows, every one SAME | SAME: 1778 rows, 0 MOVED |
| u2r census | 0 entries in 1742 invocations | SAME |
| positive control | y1 16/16 moved, y6_hoistconv 0 moved | SAME |

The eight arms CONVERTED by r11u79 and re-confirmed on the verified binary:
`va_netstructkinds`, `vd_structmem`, `vf_collide`, `xe_impkind`,
`y1_pkgnetkind`, `y2_pkgvarkind`, `y4_bindreach`, `z6_pkgconv`. The verified
binary reproduces r11u79's `cmp_rc` on ALL 38 arms — the fix changes no arm
of the submitted grid (`diff` of the two runs is empty) while clearing all
eight regressions on the verifier grid.

## 2. THE BREAK GRID — 8 NEW ARMS, 46 TOTAL, ALL `golden_rc=0 ours_rc=0`

```
  arm                faces spelled                              pris-wrong  fix-wrong
  q1_structmem       9 struct MEMBER kinds                          13          0
  q2_netkwtypes      16 net keyword x builtin data type             32          0
  q3_tdchain         15 typedef chains + a TYPE PARAMETER           18          0
  q4_unpacked        16 unpacked spellings                          30          0
  q5_impreach        wildcard / transitive / EXPLICIT import        30          8
  q6_mod77ctl        the pass-77 MODULE-side control                13          0
  q7_qual            const/var/static x struct x array x net        25          2
  q8_hopviews        chain length x the two package views           23          0
  ------------------------------------------------------------------------
  TOTAL                                                            184         10
```

Scored on the PACKAGE SECTION only, both views, through r11u79's own
`pkgscore79.py` (kind + the judge-read fields; no span, no fullname).
**MOVED-WRONG 0, AWAY-GOLDEN 0** on the verified binary: `v11u79_reg.py`
reports `REGRESSED=0 VANISHED=0` on all 46 arms.

Two slang-unreachable rows found in LAW B's comment table: `wire bit [7:0]`
and `wire byte` cannot be written at all ("`bit` is not a valid type for a
net"), so those two table rows are not backed by any measured arm. No code
path depends on them; the table should lose them.

## 3. GATES — ALL GREEN ON THE VERIFIED BINARY

- build: pristine `c56e3f2c141ee7e9a6bb41c9d4e38f8c` == main tree == OPS pin;
  r11u79 `67a6075c5d761d74bd4a28b0d0cf0b6b`; verified `ba0ff704de4ab0b0d23c7bde1be56d97`
- goldens 23/0 verified, 23/0 pristine, `/bin/false` 0/23
- u2r 788/16/67 both modes; row join vs `results/golden_uhdm2rtlil.csv`
  (BOTH modes, key `(name,mode)`, status+dump): **0 of 1742 differ**
- surelog 474/9 + 469/8; row join vs `results/golden_surelog.csv`:
  **0 of 1596 differ** — status AND dump column
- byteverify u2r **MOVERS 0/1608**, selfcheck 1607/1608
- byteverify surelog **MOVERS 6/960**, selfcheck 959/960 — every one the
  UVM family, each attributed below
- canaries ok=52 changed=0 (surelog), ok=8 changed=0 (u2r); ctcan2 PASS both
- protected DB byte pins ALL MATCH both modes: SVSwitch `4842211c4030`,
  YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, YosysOldOr
  `d68e0796d62c`, BlackParrot `e3e354129d5a`/`73a10e8217e5`, Earlgrey
  `8bdf25272e08`/`59d0ee6d10c3`
- rowheads 12 measured, 11 at `0 0 rc=0`, Rggen/default unchanged at 64/1;
  SKIP-NOFILE on Scoreboard/tf + Rggen/tf as expected
- binary audit: u2r 1742/1742 + 1742/1742, surelog 1531/1581 + 1531/1581,
  OTHER-TREE **0** in all four workdirs
- `results/*.csv` untouched

## 4. THE SIX SURELOG MOVERS, ATTRIBUTED — THREE BY EXACT HASH IDENTITY

All six are the UVM family. None carries a package-listing line: a listing
change prints `|vpiNetType:` or an object-kind line, and the order-blind
diffs below contain neither.

```
  database                    order-blind differing lines    class
  default/MiniAmiq            4  (UINT + vpiDecompile)       line-number draw
  default/SeqDriver           4  (UINT + vpiDecompile)       line-number draw
  default/SimpleUVM           4  (UINT + vpiDecompile)       line-number draw
  testflags/MiniAmiq          4  (UINT + vpiDecompile)       line-number draw
  testflags/SeqDriver         4  (UINT + vpiDecompile)       line-number draw
  default/Scoreboard          0                              pure ORDER draw
```

The POSITIVE CONTROL that convicts the environment rather than the law —
each test re-run three times from its own source directory:

```
  Scoreboard  PRISTINE x3 : 1621aec6c9f3 1621aec6c9f3 e70775324004
              ^^ byteverify read pristine=1621aec6c9f3 patched=e70775324004:
                 the pristine binary ALONE produces BOTH faces
  SeqDriver   PRISTINE x3 : 2fb39f8b4130 2fb39f8b4130 2fb39f8b4130
              VERIFIED x3 : 2fb39f8b4130 4dc026f0d9cf 2fb39f8b4130
              ^^ the VERIFIED binary lands on the PRISTINE hash
  SimpleUVM   VERIFIED x3 : ddfed11c0314 7891c94fc12e d4f8cd018f2d
              ^^ run 3 == the pristine hash d4f8cd018f2d
  MiniAmiq    PRISTINE x3 : 013368184021 bf1363762711 0e5d7553d078
              ^^ three runs, three hashes, PRISTINE binary, nothing patched
```

Every UVM row stays `CMP_EQUAL` with `cmp rc=0` (rowheads, both modes), and
the surelog row join against the committed baseline differs on **0 rows**.
All seven conversion rows hold.

`ApbSlave`, `PackageNet` and `BuildUVMPkg` carry package listings and are NOT
movers — the listing population and the mover population do not intersect,
exactly as r11u79 predicted a priori from the `R11U79LIST`/`R11U79VAR` trace
(1778 surelog rows + 1742 u2r invocations, **0 MOVED**, instrument shown to
fire on the grid at 16/16).

## 5. RANKED RESIDUES

1. **R0 — the WILDCARD-IMPORT CLONE's def-view net type is the ELABORATED
   reading.** `q5_impreach`: golden gives `pb5::a_wtd` / `pc5::a_wtd`
   (a clone of `wire aw_t a_wtd`, `typedef logic [7:0] aw_t`) `vpiNetType 36`
   in `uhdmallPackages`, where the HOME package's own entry carries `1`.
   LAW C is right for a package's OWN entry and wrong for a CLONED one: the
   clone is pushed by `importPackage` AFTER `ElaborationStep` rewrote the
   home signal, so it carries the rewritten type in both views. 2 cells, new
   here, never measured by `z7_pkgimpclone`. The next head behind this law.
2. **The EXPLICIT-import clone is not built at all.** `q5_impreach` `pd5`:
   golden lists `a_net` (logic_net), `a_uarr` (array_var) and `a_var`
   (logic_var) in both views; we list nothing. 6 cells — r11u79 declared this
   at 4 cells on `z7`; the net and array halves widen it. PRE-79.
3. **`vpiConstantVariable` missing on a `const` unpacked-array holder.**
   `q7_qual` `g_arrconst`: golden `cons=1` on the `array_var`,
   `emitPkgFixedArrayVar79` never stamps it while the scalar road does.
   2 cells, inside LAW A's own new builder. Left rather than widen the
   surface on one measured instance — the whole const/var/static x array face
   should be measured first.
4. r11u79's own residues stand and were re-measured: the package DYNAMIC
   container's `vpiAutomatic` (`z5`, 4 cells), the missing unpacked-array
   typedef in `Typespecs` (`vb`), the two-hop typedef's net typespec
   (`unsupported_typespec` vs `logic_typespec`, now the head of `z4`/`y5`).
5. The pass-77 / r11v77 residue set stands.

## 6. REPRODUCING THIS

```
GRID=<dir> bash ../r11u79repro/rr79.sh <binary> <tag>      # run the arms
python3 v11u79_reg.py <grid>                               # pristine-right -> patched-wrong
python3 v11u79_join.py <baseline.csv> <fresh.csv>          # BOTH-mode row join
GRID=<dir> R11U79_OFF=1 bash ../r11u79repro/sw79.sh <bin> off   # vs_pristine=0 on every arm
```
