# r11v81 — the verifier: it is the PATTERN's home and the SETTER's spelling, not the hop's home

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in `r11u81`'s report
reproduces bit-for-bit — both binary md5s, the 1576-cell grid (`TO=51 AWAY=0
STILL=61 WRONG2=27 EQ=1429 SHAPE=8`, per-arm identical), the census
(`AGREE81 3407 / HOP81 89 / 13 tests`), every corpus gate and the wide
boundary's `TO=73 AWAY=0 WRONG2=14`. The decoded law is right about WHAT is
handed on. It is wrong about WHERE, and the grid could not see it because no
committed arm carries the cross cell.

**THE BREAK.** Two faces of legal SystemVerilog where PRISTINE reads golden
exactly and `r11u81`'s law writes a typespec golden does not have:

| face | golden | pristine | r11u81 |
|---|---|---|---|
| a struct pattern written in a MODULE over a PACKAGE hop — qualified (`v1p::PH`) or IMPORTED bare (`PH`) | `ts=-` | `ts=-` | `int_typespec/U[15:0]` ✗ |
| a struct pattern written in a PACKAGE over a PACKAGE-QUALIFIED hop (`v13b::LH`, `v13a::BH`) | `ts=-` | `ts=-` | `int_typespec/U[15:0]` ✗ |

`6 AWAY` cells on 14 adversarial arms, `2` of them whole-cell (the rest move
the typespec of a cell whose value was already wrong). The fix removes all six
and costs **zero** conversions: the committed 34-arm grid and the 22-arm wide
boundary score IDENTICALLY on the fixed binary.

| binary | md5 | what |
|---|---|---|
| pristine | `87f32e6a31b52cd5b7766f0b8bcc731a` | `f25df07e`, built in this verification's own worktree — and identical to the rotation control `/tmp/pris_87f3.bin` |
| r11u81 law | `213d8d6a3e321e72f8d09d8a7a56c796` | the implementer's patch, byte-for-byte their claimed md5 |
| verified law | `828da107057520268bf56695974570ec` | that patch + § `patternHomeIsAPackage81v` + § `hopSpellingIsUnqualified81v` |

---

## 1. THE MEASUREMENT THAT BREAKS IT

`v13_scope81` — ONE package pattern, ONE spelling (`16'h5`), four setters, one
Surelog v1.87 run (`slrc=0 ourrc=0 slerr=0`), read with the committed
`ts81probe`:

```
  a: LH        same package, UNQUALIFIED   golden int_typespec/U[INT:15:INT:0]
  b: v13b::LH  same package, QUALIFIED     golden  ts=-
  c: BH        other package, IMPORTED     golden int_typespec/U[INT:15:INT:0]
  d: v13a::BH  other package, QUALIFIED    golden  ts=-
```

The package IDENTITY is not the discriminator — an imported name from ANOTHER
package hands its typespec on. **The SPELLING is.** A package-qualified name
is resolved by the route that MINTS a bare constant, and the mint's sizes give
it away: `v12_home81`'s qualified `5` comes out `UINT:5@64` where the
unqualified one is `@32`, and its `16'd5` comes out `INT:5` where the
unqualified one is `DEC:5`.

`v1_qualhop81` — the same package parameters (`PU`/`PH`/`PD`), four patterns:

```
  PKGSIDE  pattern in the PACKAGE                       golden int_typespec /
                                                               ranges / the empty ref
  QM       pattern in the MODULE, hops QUALIFIED        golden ts=- on all four
  IM       pattern in the MODULE, hops IMPORTED bare    golden ts=- on all four
  .R(v1p::PKGSIDE) / .R(QM) / .R(IM)                    each carries what its
                                                        SOURCE PATTERN carried
```

`IM` is the cell that refutes the spelling rule alone: the setters are bare
names to package parameters and golden still hands nothing on, because the
PATTERN is in a module. Both gates are needed, and each is measured.

`v14_read81` closes the other half — a PACKAGE pattern with unqualified
setters keeps its typespecs through EVERY read: a module parameter default, a
qualified module localparam, an imported bare module localparam and an
instance override. **The typespec rides with the pattern, not with the read.**

`v12_home81` `LREAD` is the cell that refutes the obvious repair: a PACKAGE
pattern read into a module localparam by a bare name is golden `ts=-` —
because THAT package's own setters were qualified. A gate on the READING
scope would have been wrong too.

---

## 2. THE FIX

Two § blocks in `src/ParamEmit.cpp`, each droppable alone, each ADD-ONLY (they
only ever WITHDRAW a write):

* **§ `patternHomeIsAPackage81v`** — the write site walks `sinitK.syntax`'s
  syntax PARENTS to a `PackageDeclaration`. That reads the question
  lexically — "was this pattern WRITTEN in a package" — on every substitution
  road at once (`structOvPat`, `structRefPat9`'s two sites, the parameter's own
  initializer), with no symbol road to enumerate and no road to miss. A
  pattern with no syntax answers NO, so an unknown road can only be more
  conservative. A symbol-keyed first cut of this gate was MEASURED and
  discarded: it answered NO for `.R(v1p::PKGSIDE)` and cost `v1_qualhop81`
  three real conversions.
* **§ `hopSpellingIsUnqualified81v`** — `red81HopPlan81` takes an `outer81`
  flag. At the setter's OWN name, a `SyntaxKind::ScopedName` spelling
  ABSTAINS. Casts pass the flag through (a cast does not move the lexical
  site); a hop's own INITIALIZER clears it, because that text lives in the
  hop's declaration — `v5_chain81` op2 (`localparam Bq = v5a::A;` spelled
  `Bq` in the pattern) is golden `int_typespec/U[15:0]` and still converts.

Nothing else in the implementer's patch is touched. `red81StoreCt81`,
`red81ParamStore81`'s package gate, the empty-ref fallback, the abstentions and
the write's own ADD-ONLY gate all stand as delivered.

**One more fix, not to the law:** `evidence/GATES.post.r11u81.txt` SPELLED the
four slang-fenced test names, and `canaudit.sh` excludes only itself and
`README*.md` — so the delivered tree failed the pass's own fence audit
(`FENCE-BREACH=4`, exit 6, no `PASS` line; the master's integration gate reads
that line). The four names are redacted to `<fenced-N>` in that RECORD and the
audit now reads `audited=29 UNCOVERED=0 FENCE-BREACH=0 PASS`.

---

## 3. WHAT REPRODUCED, EXACTLY

| claim | verifier's reading |
|---|---|
| pristine md5 `87f32e6a…`, law md5 `213d8d6a…` | both exact, built `-j 2` in fresh worktrees at `f25df07e` |
| grid `TO=51 AWAY=0 STILL=61 WRONG2=27 EQ=1429 SHAPE=8` | exact, and every per-arm line (`a1` 10/0/1/2/25, `a4` 12/0/0/0/16, `x9c_cast73` 2/0/0/0/10 …) |
| scorer positive control (swap the binaries) | `a1_hopts81` `TO=10 → AWAY=10` |
| goldens 23/0, `/bin/false` 0/23 | exact, on both binaries |
| u2r `788/16/67` both modes, row-join `DIFF=0` ×3 | exact; the two sweeps' CSVs are byte-identical |
| u2r byteverify `MOVERS 0/1608`, selfcheck `1607/1608` | exact |
| surelog `474/9 + 469/8`, own-pristine `DIFF=0` | exact |
| surelog vs committed CSV: 2 rows, both `Earlgrey_0_1`'s DUMP COLUMN | exact — **and the PRISTINE sweep drew the same blank**, so it is the environment, not the law |
| surelog byteverify 4/960, all the UVM coin | 4 movers, a DIFFERENT draw (`MiniAmiq`×2, `SimpleUVM`, `SeqDriver`), each exactly **4 sorted lines**, one `UINT`/`vpiDecompile` pair holding a line number, zero `vpiConstType`/`vpiSize`/`vpiTypespec` lines |
| coin positive control | stronger: **four** runs of the SAME pristine binary on ONE invocation gave **four** distinct databases, differing in exactly that class |
| canaries `ok=50 changed=2` / `ok=16 changed=0`, ctcan2 PASS ×2 | exact; the 2 changed are the Earlgrey dump cells and the pristine sweep shows the same 2 |
| protected DBs at the pinned md5s | exact: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`, InterfaceModPort `59a365f3ce2c`, Earlgrey `8bdf25272e08`/`59d0ee6d10c3`, BlackParrotComplex and YosysOldOr SAME |
| conversion rows 0 cmp / 0 heads | exact, both modes; `ParamOverloading` 0/0 restored; `Rggen`/default 64/1 |
| census `AGREE81 3407 HOP81 89`, 13 tests, SELFTEST PASS | exact **under the documented recipe** — see §4 |
| wide boundary `3214 SAME / 22 DIFFERS / 39 NODB`, scored `TO=73 AWAY=0 STILL=67 WRONG2=14 EQ=510` | the SAME 22 arms and the SAME score — see §4 for the arm count |
| `results/*.csv` untouched, every `cmds.txt` audited | exact: 1742 u2r + 1596 surelog rows per binary, **0 name the main tree** |

---

## 4. THREE EVIDENCE WARTS (none of them a defect in the law)

* **The wide boundary omitted its own four arms.** The README says "3275 arms
  … this pass's four included", but `3214 + 22 + 39 = 3275` and the four
  `a*_81` arms all DIFFER. The verifier's list is **3279**: `3214 SAME /
  26 DIFFERS / 39 NODB`, the extra four being `a1`–`a4`.
* **`census81.py --selftest` FAILS from the committed directory.** It reads
  `HERE/grid`, which holds only this pass's four arms, and then demands
  `x9c_cast73`, `z1_ts78`, `z2_hop78`, `v3cast76` and `y3_castenc76` — arms
  that live in other probe directories. It PASSES from the scratch dir the
  README's §7 recipe builds, which is where the claim was taken. The
  negative control is also vacuous in place (0 arms unsighted, against 23 in
  the recipe's dir).
* **`canaudit.sh` FAILS from the committed directory** — the fence breach in
  §2, now fixed.

---

## 5. THE ARMS

`grid/` — 14 arms, every one a real Surelog v1.87 run through the committed
`r11u81repro/run66.sh`, all `slrc=0 ourrc=0 slerr=0` on all three binaries,
scored with the committed `r11u81repro/score81.py` + `ts81probe`.

| arm | what it asks |
|---|---|
| `v1_qualhop81` | package hop from a MODULE pattern, qualified and imported, plus the three instance overrides — **2 whole-cell AWAY** |
| `v12_home81` | a PACKAGE pattern whose own setters are qualified, read into a module localparam — **2 AWAY** |
| `v13_scope81` | same/other package × qualified/unqualified in ONE package pattern — **2 AWAY**, and the rule |
| `v14_read81` | one package pattern, four different READS (default, qualified, imported bare, override) — 12 TO, no AWAY |
| `v2_store81` | string / 1-bit based / concat / ternary / `$clog2` / zero / negated hex / 96-bit hex / declared-type chain stores |
| `v3_real81` | a REAL and a STRING store (golden `real_typespec` / `string_typespec`; the law correctly writes neither) |
| `v4_xdig81` | unknown-digit stores — the refusal guard's ground |
| `v5_chain81` | cross-package hops, and a hop whose OWN initializer is qualified (still converts — the flag is per lexical site) |
| `v6_arr81` | a packed-ARRAY pattern, not a struct |
| `v7_defrep81` | `default:` setters |
| `v8_cast81` | stacked `signed'(unsigned'(…))`, width casts over names |
| `v9_kwd81` | `parameter` (not `localparam`) in a package; an untyped hop over a declared-type name |
| `v10_nest81` | nested patterns and an UNPACKED struct parameter |
| `v11_neg81` | `-16'd5`, `16'sb101`, `16'sh5`, `16'so5` one hop up (RV-4's ground) |

`bnd3v81.sh` — the three-way wide boundary driver (pristine / law / fix, all
three writing ONE file name in ONE directory, because the serializer embeds the
output path).

```bash
# the arms
G=/tmp/g81v && mkdir -p $G/grid && R=<tree>/tools/probe
cp $R/r11u81repro/{score81.py,run66.sh,ts81probe.cpp} $G/
cp $R/r11v81repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/v11u81_bin/pris.bin
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/v11u81_bin/lawx.bin
  bash $G/run66.sh $G/grid/$a.sv fixx /tmp/v11u81_bin/fixx.bin
done
python3 $G/score81.py $G/grid pris lawx      # TO=32 AWAY=6
python3 $G/score81.py $G/grid pris fixx      # TO=32 AWAY=0
# the boundary (TAGS AND WORKDIR NAMES THE SAME LENGTH — r11u81's RV-7)
BND_PRIS=… BND_LAW=… BND_FIX=… BND_ROOT=<tree>/tools/probe BND_OUT=/tmp/bnd \
  xargs -P 3 -n 1 bash $R/r11v81repro/bnd3v81.sh < armlist.txt
```

---

## 6. RESIDUES THE VERIFIER ADDS

* **RV81-1 — the qualified-name route is transcribed, not pinned.** The
  SHAPE is measured on twelve golden cells across four arms and refuted by
  none, and the mint's sizes (`UINT:5@64`, `INT:5`) point at the simple Value
  store (`CompileExpression.cpp:962-985`) against the `param_assign` clone
  (`:920-955`). The exact line that decides between them for a
  `ScopedName` was not found. Same standing as the implementer's RV-1.
* **RV81-2 — golden's MODULE-route constants are a second, unclaimed face.**
  On every module-homed pattern golden's hop constants differ from ours in
  SIZE and CONSTTYPE too (`UINT:5@64` vs our `@32`; `INT:5` vs our `DEC:5`).
  Those cells are STILL-wrong on both binaries and no law here touches them;
  they are a fold-encoding pass's ground, and worth `~6` cells per arm.
* **RV81-3 — `ts81probe`'s key COLLIDES.** It keys on (section, LHS name,
  op type), so three instances of one sink module all named `R` overwrite each
  other and only the LAST is scored. It hid one of `v1_qualhop81`'s AWAY
  cells until the databases were read directly. A future generation should key
  on the parameter's full path.
* **RV81-4 — a package pattern whose setter is a TERNARY over a hop is a
  missed conversion**, not a regression: `v2_store81` op4
  (`localparam QQ = (1 ? 5 : 6)`) is golden `int_typespec/U` and the law
  abstains. One cell, on the encoding table's road.
* The implementer's RV-1 … RV-8 were re-read and none is contradicted. RV-7
  (the workdir is IN the database) was honoured throughout: every tag and
  workdir name in this verification is four characters (`pris`/`lawx`/`fixx`).
