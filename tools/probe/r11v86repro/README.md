# r11v86 — the adversarial verification of r11u86

**VERDICT: ACCEPT WITH CORRECTIONS.**  The law § `modPatHopValueStoreEnc86` is
sound: on eight new adversarial arms and every committed arm re-scored with an
alignment-aware scorer, **AWAY = 0 and MOVED-WRONG = 0 on every axis**, and the
whole pristine→law delta across all 34 arms is confined to `vpiConstType`,
`vpiValue` and `vpiDecompile` — **zero lines of any other class**.  Three of the
pass's own claims are contradicted by measurement and are corrected in
`r11u86repro/README.md` (§3.4, §3.8, §5b.8); none of them is a defect in the
code, all three are defects in the report.

Base `85da93e6`, pins per `SUPPORT_MATRIX.md`.  Both binaries built in this
verification's own worktrees and frozen `chmod 555` before any sweep:

| binary | md5 |
|---|---|
| pristine (`/tmp/wt_v11u86pris`) | `23aace417bcebd92ef0afde8a20a8a1e` — byte-identical to the main tree at `85da93e6` |
| law (`/tmp/wt_v11u86`) | `7a4c780d71aa71fd643b77e4314676b4` |

Both reproduce the pass's stated values exactly.

---

## 1. WHAT WAS REPRODUCED BIT-FOR-BIT

* the two md5s above; the patch applies clean on a fresh `85da93e6` worktree;
  surface = `src/ParamEmit.cpp` + `src/EmitHelpers.h` + `tools/probe/r11u86repro/`
  only; `results/*.csv` and `src/ModuleEmit.cpp` untouched; none of the four
  slang-fenced names appears in any file of the patch.
* the grid score on the committed scorer: **TO=49 AWAY=0 STILL=95 WRONG2=7
  EQ=195 SHAPE=14**, per arm as printed.
* goldens **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` **0 PASS / 23 FAIL**.
* uhdm2rtlil **788 / 16 / 67** in each mode on each binary; the 1742-row
  BOTH-MODE join against `results/golden_uhdm2rtlil.csv` **byte-identical, every
  row**, on BOTH binaries; the testflags rows against
  `results/gate_uhdm2rtlil.csv` likewise; `byteverify` **MOVERS 0 / 1608**,
  selfcheck **1607 / 1608**.
* the census: **AGREE86 15198 / HOP86D 0 / HOP86O 0 / HOP86U 236**, 20 candidate
  tests, `SELFTEST PASS`; and the cross-file confirmation re-run independently —
  each of the **78 distinct** `HOP86U` names searched for a
  `parameter|localparam <name> = <'d|'o literal>` declaration across all three
  corpus roots, **0 hits**.
* every `cmds.txt` audited by ABSOLUTE binary path: 1742 u2r + the surelog set,
  **0 naming the main tree** on either binary.

### the producer decode, checked line by line against Surelog v1.87 (`0445655ee7`)

LAW A is correct as written.  `CompileExpression.cpp:2876-2877` is
`if ((reduce == Reduce::Yes) && instance) sval = instance->getValue(name);`;
`:2882` forks on `sval == nullptr || !sval->isValid()`; the `else` at
`:3028-3041` mints `VpiValue(sval->uhdmValue())` / `VpiDecompile(...)` /
`VpiConstType(...)` / `VpiSize(...)`.  `Value.cpp:282-288` renders `INT:`/`UINT:`,
`:314-321` the bare decimal digits, `:341-346` `vpiIntConst`/`vpiUIntConst`;
`Value.h:178-181` is the hard-coded `m_size(64)` behind the `UINT:5@64`.

LAW B's pin is correct as written.  The `paPackage_scope` branch opens at
`:2723`, clones at `:2745`, falls back to `pack->getValue(n)` at `:2764`, and the
`paClass_type` twin at `:2769` clones at `:2793` and falls back at `:2802`.
Neither contains a `tps` or `Actual_typespec` statement; the two hand-on blocks
are at `:2907-2927` and `:2976-2995`, both reachable only past the
`if (result) break;` at `:2880`.  The landed fence sits inside a
`NamedValue`-only arm (`ParamEmit.cpp:1027-1053`), so it cannot mis-fire on a
dotted hierarchical name — the claim holds.  **A pin, no code, no risk.**

---

## 2. BREAKING THE LAW — EIGHT NEW ARMS, ALL ON REAL v1.87 GOLDENS

Every arm records `slrc` / `ourrc` / `slerr`; **all eight read `0 0 0` on both
binaries.**  Scored per cell and per field with `score86v.py` (below) and read
cell by cell with `cells86.py`.

| arm | the attack | result |
|---|---|---|
| `z1_decl86` | the hop's DECLARED type decides the store, not the literal's base: `bit [15:0]`, `byte`, `int`, `int unsigned`, `integer`, `shortint`, `logic signed [15:0]`, and a `bit`-typed octal | REFUTED — golden is `INT:`/`UINT:` on every one; **TO=14 AWAY=0 MWRONG=0** |
| `z2_view86` | the DEF view of a NON-TOP module, and a parameter DECLARED INSIDE a generate block | golden takes the same route; the law fires correctly in the gen scope and **never fires in the def view** (the def-view region of the dump is byte-identical between the binaries); **TO=8 AWAY=0** |
| `z3_width86` | truncation: `16'd300`/`16'd65535`/`16'o377` into 8-bit members, `32'd16777216`/`32'o77777777` into 24-bit ones | golden does NOT truncate — full digits, and the law's digits match; **TO=12 AWAY=0** |
| `z4_route86` | a module localparam whose own initializer is a QUALIFIED package hop; an imported-bare hop; a port parameter OVERRIDDEN with `'d`; one left at its `'o` default; a forward chain; an operation-valued hop; a width-cast hop | every one golden's; **TO=14 AWAY=0** |
| `z5_home86` | homes that are neither module nor package: a `$unit` (compilation-unit) pattern and an INSTANTIATED INTERFACE | the law is correct on both; golden emits NO `param_assign` for the `$unit`-fed sink where ours emits one (both binaries) — RV86-4 |
| `z6_sign86` | SIGNEDNESS against the octal arm: `signed [15:0] = 16'o5`, `16'so17`, `int signed = 16'o17`, `logic signed [15:0]`, and the four cast faces | REFUTED — a signed octal is golden `UINT:` too; **TO=10 AWAY=0 MWRONG=0** |
| `z7_trunc86` | a DECLARED WIDTH narrower than the literal (`bit [7:0] = 16'd300`, `bit [3:0] = 16'd300`, `shortint = 32'd70000`) | golden keeps the literal's digits AND the literal's width; the law's digits match; **TO=10 AWAY=0** |
| `z8_ctx86` | the context axis widened: `'{default: 'o hop}`, a REPLICATION, an unpacked array, a NESTED struct member, a package-hop array | the named roads are golden's; the `'{default:}` road is NOT written — RV86-2 |

**TOTAL over all 34 arms, alignment-aware: TO=130, AWAY=0, MOVED-WRONG=0.**
(`score86v.py` flags 2 cells on `z5_home86` and 1 on `z8_ctx86`; all three are
the section-pairing artefact of RV86-3 and resolve to agreement when the sections
are paired by content — our extra sink section shifts the zip.)

**THE DEF-VIEW GUARD, measured not assumed.**  On all 34 arms the FIRST differing
dump line is after the `uhdmtopModules` boundary.  The law writes only in the
elaborated view, which is exactly where golden's Value store answers; the def
view — where golden's `instance` is absent and the clone route keeps `DEC:` —
is never touched.  That is the structural reason no `bit`/`byte`/generate/def
shape produced a MOVED-WRONG.

**THE WIDE BOUNDARY, re-run: 3384 arms → 3336 SAME / 9 DIFFERS / 39 NODB**, every
NODB with `prc == lrc`.  Eight of the nine were named a priori; the ninth is
`m7_if86` (see RV86-1).

---

## 3. THE THREE CORRECTIONS

**RV86-1 — `m7_if86` IS NOT INERT, AND THE BOUNDARY COUNT WAS 9, NOT 8.**
r11u86 §3.8 states "PRISTINE and LAW carry the same 24 … the two databases
differ only in the workdir string the serializer embeds" and "the sister pass's
interface-emission ground is untouched by construction".  Measured: the
path-neutral `bnd72.sh` reports `ARM m7_if86.sv prc=0 lrc=0 DIFFERS`, and the
path-normalised dump diff is 24 lines over 4 cells —
`work@m7_if86.u.IFP` and `.IFM`, each moving `DEC:5 d=16'd5 → INT:5 d=5` and
`OCT:17 d=16'o17 → UINT:15 d=15`.  **Golden carries exactly those values**
(`INT:5` and `UINT:15` on the elaborated `interface_inst`), so the writes are 4
TO cells with 0 AWAY — the law is RIGHT and the report was wrong.  The cause is
instrumental: `ts81probe` walks `TopModules()` and their `Modules()` and never
enters an `interface_inst`, so the arm scored zero cells and the DEF-view
`tagged_pattern` listing was read as the whole answer.  The `8 DIFFERS` line then
simply lost the arm.  Consequence for integration: this law DOES rewrite three
fields on interface-homed elaborated `param_assign` operands.  It does not edit
`ModuleEmit.cpp` and `InterfaceModPort` stays byte-pinned, but the sister pass
should not be told the interface objects are untouched.

**RV86-2 — THE LAW IS NOT CONTEXT-FREE; `'{default:}` AND ARRAY ELEMENTS ARE NOT
WRITTEN.**  §3.4 reads "The ENCODING is uniform across all of them … which is
what makes this law context-free".  Golden's encoding is indeed uniform, but the
law abstains on two of the roads: `m4_ctx86`'s `DFLT` section (4 cells) and `AR`
section (2 cells) stay `DEC:`/`OCT:` on BOTH binaries where golden is
`INT:5`/`UINT:5`, and `z8_ctx86` repeats it for `'o` (`'{default: MO}` 3 cells,
the replication sink 3 cells).  These are STILL, never AWAY — a coverage gap, not
a regression.  R0 names only the SIZE face of those two roads; the ENCODING face
is unclaimed there.

**RV86-3 — `score86.py` MIS-PAIRS SECTIONS WHEN THE SECTION COUNTS DIFFER.**  The
scorer zips golden's section list against ours positionally.  Our binary emits a
different number of `param_assign` sections on `m3_gate86` (5 vs golden 6) and
`m4_ctx86` (7 vs 8), so from the first divergence every cell is compared against
the WRONG golden section — on `m3_gate86` a module `R` section against the
package control, which is where its `SHAPE=8` came from.  Re-scored with
`score86v.py`, which aligns the section lists with `difflib` on (kind, name,
optype, operand count) first: **TO and AWAY are unchanged (49 / 0)**, `m3`'s
`SHAPE` falls to 0 and `m5_bnd86` / `v4_xdig81` fall out as UNPAIRED because
their operand counts differ (r11u78's R4).  No AWAY was hidden — but the
instrument could have hidden one, and this is the same class as the pass's own
R4.

---

## 4. RESIDUES THE PASS DID NOT NAME, RANKED

* **RV86-A (largest) — GOLDEN'S MODULE-ROUTE MINT WRITES A SIGNED
  `int_typespec` AND WE WRITE NONE.**  The pass quotes the block
  (`CompileExpression.cpp:3032-3040`, `if (sval->isSigned()) { … int_typespec
  … VpiSigned(true) … }`) in §1.1 and then names only the CONVERSE as R1.  The
  missing direction is bigger: **22 cells on the two new arms alone**
  (`z1_decl86` 6, `z6_sign86` 16) where golden's operand carries
  `int_typespec/S` and both our binaries carry none — `int`, `logic signed
  [15:0]`, `signed [15:0]` and `int signed` hops, exactly the cells this law
  has just converted to `INT:`/`UINT:`.  Present on both binaries, so no
  regression; it is the natural next half of the same producer block and it is
  an ADD, not a replace.
* **RV86-B — the `'{default:}` / array-element ENCODING gap** (RV86-2 above).
  Six cells on the committed grid, six more on `z8_ctx86`.
* **RV86-C — golden's module-route SIZE is the LITERAL's written width even when
  the parameter's declared type is narrower.**  `localparam bit [7:0] ZT8 =
  16'd300` is golden `16@7 INT:300`; ours reads the DECLARED width, `8`.  A face
  of R0 the pass's table does not list (its table covers unsized, package-hop and
  operand-reduced widths only).  `z7_trunc86`, 6 cells.
* **RV86-D — a `$unit`-homed struct pattern.**  Golden emits no `param_assign`
  for the sink it feeds; ours emits one (`z5_home86`, both binaries).  A SHAPE
  residue of the same family as the pass's R3.
* **RV86-E — an elaborated GENERATE-SCOPE parameter's OWN constant.**  Golden
  renders it through the Value store (`localparam ZGD = 16'd6` → `d=6`,
  `ct=7`); ours keeps the written literal (`d=16'd6`, `ct=1`).  The
  module-level case already agrees, so this is a gen-scope-only gap in the same
  encoding face the law just landed for pattern operands.  `z2_view86`,
  2 cells.

---

## 5. REPRODUCING

```bash
git worktree add /tmp/wt_v11u86pris 85da93e6 && git worktree add /tmp/wt_v11u86 85da93e6
(cd /tmp/wt_v11u86 && git apply /tmp/r11u86.patch)
for d in /tmp/wt_v11u86pris /tmp/wt_v11u86; do
  cmake -S $d -B $d/build -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER=/opt/rh/gcc-toolset-14/root/usr/bin/c++ \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
  cmake --build $d/build -j 2; md5sum $d/build/slang-uhdm; chmod 555 $d/build/slang-uhdm
done
G=/tmp/v11u86_g && mkdir -p $G/grid && R=/tmp/wt_v11u86/tools/probe
cp $R/r11u86repro/{run66.sh,ts81probe.cpp,census86.py} $G/
cp $R/r11v86repro/{score86v.py,cells86.py,tsmiss.py} $G/
cp $R/r11u86repro/grid/*.sv $R/r11u81repro/grid/*.sv $R/r11v81repro/grid/*.sv \
   $R/r11v86repro/grid/*.sv $G/grid/
(cd $G && g++ -O1 -std=c++20 ts81probe.cpp -o ts81probe \
   -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj)
for a in $(ls $G/grid/*.sv | xargs -n1 basename | sed 's/.sv$//'); do
  bash $G/run66.sh $G/grid/$a.sv pris /tmp/wt_v11u86pris/build/slang-uhdm
  bash $G/run66.sh $G/grid/$a.sv lawx /tmp/wt_v11u86/build/slang-uhdm
done
python3 $G/score86v.py $G/grid pris lawx      # TO=130 AWAY=0 MWRONG=2(artefact)
python3 $G/cells86.py  $G/grid z1_decl86 … z8_ctx86
python3 $G/tsmiss.py   $G/grid                # RV86-A's cell counts
# the DEF-VIEW GUARD, per arm: the first differing dump line must be AFTER
# the `uhdmtopModules` line of that arm's dump.
# the wide boundary, path-neutral (bnd72.sh writes both databases into ONE dir):
#   3384 arms -> 3336 SAME / 9 DIFFERS / 39 NODB
```

Evidence: `evidence/{GRID86V.score,CELLS86V,TSMISS86V,BOUNDARY86V.summary,
BOUNDARY86V.differs,CENSUS86V}.txt`.
