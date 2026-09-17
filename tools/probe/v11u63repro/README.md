# v11u63 — ADVERSARIAL VERIFICATION of r11u63 (§ connPathRootOwnTs63) — ACCEPT

Base `9dc8c859`. Verifier worktrees `/tmp/wt_v11u63` (law) and
`/tmp/wt_v11u63pris` (pristine), both built from scratch by this verifier.
Frozen binaries `/tmp/v11u63_bin/{pris,law}.bin`, workdirs
`/tmp/v11u63_wd_{pris,law}`. Nothing in this directory reruns another pass's
scratch; every driver takes its workdirs as parameters.

**VERDICT: ACCEPT, unchanged.** Every headline number reproduced bit-for-bit
from binaries this verifier built. Three NEW breaker grids (79 rows, 63 of them
on faces the implementer's g1/g2/g3 do not cover) found **0
pristine-right → patched-wrong cells on legal SV** and **+23 further
conversions**. No fix was needed, so there is no `.verified.patch`.

---

## 1. WHAT REPRODUCED BIT-FOR-BIT

| claim | verifier's own measurement |
|---|---|
| pristine md5 | `5fc453cd3a119cc5de0debfa68714d63` — the OPS-pinned value |
| law md5 | `44a1172e38bf2ac198365a9b15aea810` |
| witness head, pristine | 17 cmp lines / 1 head BOTH modes; `LHS: ref_typespec: (work@tb.t.m.c.a_i.fu_data_i.operand_a), id:451` ... `RHS: <null>` — ids 451/450/361 identical |
| witness head, law | 36 cmp lines / 1 head BOTH modes; new head = the `dut.sv:31` pattern operand, golden `vpiSize:1` vs ours `vpiSize:64` |
| ADVANCE not CONVERT | row stays `CMP_NOTEQUAL` both modes; whole-dump order-blind residue 149/37 -> 143/38 |
| g1 / g2 / g3 | calib 43/22/11 rows 0 DIFF; pristine 40/21/4 -> law 43/21/6; combined 65/76 -> 70/76 |
| ids: share not clone | golden `#306/#309/#315 -> #337`; ours `#378/#382/#388 -> #405` |
| Surelog source | `CompileExpression.cpp:5478-5494` transcribed exactly; `hier_path::Compare` runs `expr::Compare` (VpiDecompile, VpiSize, **Typespec**) BEFORE Path_elems / Root_value / VpiName |
| prediction u2r | 2 arms of 1608, both `struct_member_cfg_width` — reproduced from this verifier's own pristine databases |
| prediction surelog | 0 of 960, with 13 face-holding tests named |
| u2r movers | `MOVERS 2/1608`, `SELFCHECK 1607/1608`, `PATH_SETS_IDENTICAL` |
| u2r census | 21 scored x 2 modes, calib 0 DIFF each, TO-GOLDEN 1 / AWAY 0 / UNCHANGED 20 |
| surelog census | 13 scored, calib 0 DIFF each, TO-GOLDEN 0 / AWAY 0 / UNCHANGED 13 (Earlgrey 14478 keyed rows) |

**One number did NOT reproduce, and it is not the patch.** This verifier read
**4** surelog movers, not 3: `MiniAmiq` BOTH modes, `Scoreboard/default`,
`SeqDriver/testflags`. All four are the documented coin, and the positive
control is decisive — see `evidence/COIN.posctl.txt`. `Scoreboard/default` is
the sharpest: the SAME frozen PRISTINE binary, re-run five times, produced the
pristine sweep's hash once and the LAW sweep's hash `1621aec6c9f3` four times.

---

## 2. THE BREAKER GRIDS (this verifier's own, Surelog v1.87 golden, every arm rc=0 / 0 `[ERR`)

Scored with the implementer's SHAPE LISTER `hpgrid63`, calibration
golden-vs-golden FIRST on each: b1 38 rows, b2 25 rows, b3 16 rows, all 0 DIFF.

### b1 — [grid/b1_break63.sv](grid/b1_break63.sv), 38 rows: faces g1/g2/g3 do not cover
Hierarchical root; interface-instance root; interface-array root; type-parameter
root inside a for-generate, inside an if-generate, in an INSTANCE ARRAY, 3-deep
nested, UNION-typed, unpacked-array element select, member-then-bit-select,
inside concat / replication / ternary, re-passed two levels; package-variable
root; typedef'd unpacked-array root; `.*` wildcard.

**Pristine 23/38 -> law 36/38. THIRTEEN cells CONVERT. 0 pristine-right ->
patched-wrong.**

Two cells remain wrong, and neither is caused by this law:
* `pin[1].a` on a type-parameter unpacked-array port — our root is an
  `array_net` where golden's is an `array_var`, and our `array_net` carries no
  typespec, so fence F4 declines. Pre-existing, unchanged.
* `gvv.a` where `gvv` is declared INSIDE a generate block with a
  TYPE-PARAMETER type — **see §3.**

### b2 — [grid/b2_decline63.sv](grid/b2_decline63.sv), 25 rows: THE DANGEROUS FACE
Roots where GOLDEN DECLINES the edge but our `parentNets` holds an `expr` that
HAS a typespec: plain interface port, modport-qualified port, interface-array
port element, unnamed generate block, wildcard package import, generate-CASE
block, struct localparam, struct parameter, a connection reached only through a
`bind`, a top-level struct, two named connections on one instance, and a NAMED
connection on an OUTPUT formal.

**Law byte-identical to pristine: 0 cells move.** The pre-existing residues
(`p[0].v.a` root kind, `pgv` root kind, three ONLY-OURS paths golden folds) are
untouched. **This is the grid that would have convicted the law, and it does
not.**

### b3 — [grid/b3_esc63.sv](grid/b3_esc63.sv), 16 rows: ESCAPED-IDENTIFIER roots
The documented trap of this very helper: `\pin.i .a` (escaped root containing a
DOT), `\p[0] .a` (containing a BRACKET), and `{a.a, \a.b .a}` — a plain root
`a` and an escaped root `\a.b` colliding on the same head in ONE concat. Plus an
anonymous-struct root in an if-generate, a nested for-in-if generate, and a
NAMED and a POSITIONAL instance of the same module side by side.

**Pristine 8/16 -> law 14/16. SIX cells CONVERT.** Every escaped root resolves
correctly — the new arm inherits the shipped longest-whole-component root finder
and never splits the printed text. The positional instance `up` is left EXACTLY
as pristine while its named neighbour `un` converts, which proves the fence is
**per connection**, not per module.

**COMBINED, all three: 79 rows, pristine 53 right -> law 76 right, +23,
0 MOVED-WRONG, 0 AWAY-GOLDEN.**

---

## 3. THE ONE CLASS WORTH NAMING (a residue, not a regression)

Two cells go from MISSING typespec to WRONG-VALUED typespec:

| cell | golden | pristine | law |
|---|---|---|---|
| b1 `tb.i20.og[0].u` `gvv.a` | `struct_typespec:pk63::st_t` | `ts=<none>` | `ts=logic_typespec:` |
| b3 `tb.i6.u` `pin.a` | `logic_typespec:` (Surelog itself failed `type(anon)`) | `ts=<none>` | `ts=struct_typespec:` |

**Both are the ROOT OBJECT'S OWN defect, already CMP_NOTEQUAL in pristine**, and
the law copies the root's actual exactly as its decoded model says. Proved from
the pristine dump: our `struct_var (work@tb.i20.og[0].gvv)` carries
`ref_typespec -> logic_typespec` where golden's carries
`ref_typespec -> struct_typespec (pk63::st_t)` — a **generate-block-local
variable declared with a type-parameter type does not specialize in our
emitter**, and `variables::Compare` reads `Typespec`, so that object was
not-equal before this pass existed. The law creates no new not-equal object and
changes no verdict; only which field the head names on that path.

Fixing it means fixing the ROOT's emission, which is the type-parameter
specialization family, not this one.

---

## 4. GATES, RE-RUN BY THIS VERIFIER

| gate | result |
|---|---|
| (1) builds | pristine `5fc453cd…` (the OPS pin, byte-identical to the main tree at `9dc8c859`); law `44a1172e…`; `ParamEmit.cpp` untouched |
| (2) goldens | `PASS=23 FAIL=0`; `SLANG_UHDM=/bin/false` -> `PASS=0 FAIL=23` |
| (3) u2r both modes | `786/18/67` x2 on BOTH binaries; 1742 rows joined against `results/golden_uhdm2rtlil.csv` = **0 differing** for law AND pristine; `gate_uhdm2rtlil.csv` PASS; law-vs-own-pristine PASS both modes; all **1742** `cmds.txt` audited by binary PATH |
| (4) surelog `--mode both` | `474/9` + `469/8` on BOTH binaries; law-vs-pristine = **2 differing rows**, both the `SURELOG_FAIL` detail quoting the WORKDIR PATH (`LowMemLib`, `LowMemPkg`) |
| (5) byteverify SELFCHECK=1 | u2r `MOVERS 2/1608`, SELFCHECK `1607/1608`; surelog `MOVERS 4/960`, SELFCHECK `959/960`; `PATH_SETS_IDENTICAL` both |
| canaries | u2r `ok=8 changed=0 absent=0` (identical pristine and law); surelog `ok=51 changed=1` **identically on BOTH binaries** — the one is `Earlgrey_0_1/testflags` `CMP_EQUAL/differ -> CMP_EQUAL/`, the documented uhdm-dump timeout draw in the DUMP COLUMN, status unchanged and its DATABASE at the pin |
| ctcan2 | PASS x2 (`ok=58` surelog, `ok=1` u2r, `changed=0`) |
| canaudit | `audited=29 UNCOVERED=0 FENCE-BREACH=0`; the pass's `canaries.sh`/`ctcan2.sh`/`canaudit.sh` are byte-IDENTICAL to `r10uvm221repro`'s |
| rowheads | SeqDriver / SimpleUVM / Scoreboard / MiniAmiq / BuildUVMPkg / Earlgrey_0_1 `0 lines 0 heads`; Rggen `64 lines 1 head` — identical pristine and law |
| protected DBs | `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a`, `InterfaceModPort 59a365f3ce2c`, `Earlgrey_0_1` default `8bdf25272e08` / testflags `59d0ee6d10c3`, plus `BlackParrotComplex` and `YosysOldOr` — **every one byte-identical pristine to law, every hard pin at its OPS value** |
| UVM family | all five `CMP_EQUAL` |
| landed conversions | `iface_zero_width_field`, `indexed_partsel_array` `CMP_EQUAL` both modes |
| fence | `0 0 0 0` |
| `results/*.csv` | untouched; main tree clean |
| clean apply | `git apply --check` and `git apply` rc=0 on a FRESH `9dc8c859` worktree; the regenerated production diff md5 `a4d48e93ef04587e1907ed8951adb0c6` matches this verifier's worktree exactly; surface = `src/ModuleEmit.cpp` + `include/UhdmExporter.h` + `tools/probe/r11u63repro/` only |

---

## 5. REPRODUCING THE BREAKER GRIDS

```bash
cd <scratch>
cp <repo>/tools/probe/v11u63repro/grid/*.sv .
cp <repo>/tools/probe/r11u63repro/{hpgrid63.cpp,tsid63.cpp,predict63.cpp,faceset63.cpp} .
for f in hpgrid63 tsid63 predict63 faceset63; do
  g++ -O1 -std=c++17 $f.cpp -I ~/.local/include -L ~/.local/lib64 -L ~/.local/lib \
      -luhdm -lcapnp -lkj -o $f; done
for g in b1_break63 b2_decline63 b3_esc63; do
  mkdir -p run_$g && (cd run_$g && cp ../$g.sv . && \
    ~/git-repos/Surelog/build/bin/surelog -parse -nobuiltin -nocache -sv -d uhdm $g.sv && \
    cp slpp_all/surelog.uhdm ../$g.golden.uhdm)
  $PRIS_BIN $g.sv --single-unit -o $g.pris.uhdm
  $LAW_BIN  $g.sv --single-unit -o $g.law.uhdm
  ./hpgrid63 --rows $g.golden.uhdm $g.golden.uhdm | tail -1   # CALIBRATION: DIFF 0
  ./hpgrid63 $g.golden.uhdm $g.pris.uhdm
  ./hpgrid63 $g.golden.uhdm $g.law.uhdm
done
```

An arm whose slang compile fails teaches error recovery, not golden: two cells
were removed for that reason and the removal is recorded in the source
(`b1` module-in-interface, `b3` a member read on an unspecialized `T`).
