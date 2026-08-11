# r10uvm49repro — pass 49 VERIFIER SALVAGE (no implementer patch existed)

Everything below was measured by the pass-49 **verifier** on its own build in its
own worktree at base **133f5ee**, on 2026-08-11. Nothing here is inherited.

**LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.** `uhdm-cmp` is
`/home/heyfey/.local/bin/uhdm-cmp` and takes `(golden.uhdm, ours.uhdm)` in that
order. Every dump excerpt is passed through `sed 's#/home/[^ ,]*/##g'`.

## 0. Why this directory exists

`/tmp/r10uvm49.patch` **never existed**. The implementer (worktree
`wf_9b349e10-e76-1`) configured a control build at 02:41, built it at 02:44,
took the UVM-4 head census at 02:46, built two golden-reading probes at 02:48
and 02:51, wrote and ran **one** arm (`t49a`) at 02:56–02:57, and then stopped
without reporting. Every `src/*.cpp` in that worktree still has the 02:40
checkout mtime and its `src/ParamEmit.cpp` md5 is
`d41c69719722a890995848cec20e9bcc`, **byte-identical to pristine 133f5ee**. So
**no emitter code was ever written** and there was nothing to gate.

What the implementer *did* leave was `t49a` — the decider arm — already run but
never read. Reading it inverts the pass. That reading, cleaned up and extended
to six arms, is this directory.

## 1. Binary provenance

| item | value |
|---|---|
| my build | `build/slang-uhdm` md5 `570b867dc631e11b728ee1b058e29fa8` |
| main-tree build | `/home/heyfey/git-repos/slang-uhdm/build/slang-uhdm`, same md5 |
| md5 before / after every sweep | unchanged (`uvm4both.sh` prints both) |

My from-scratch build of pristine 133f5ee is **byte-identical** to the main-tree
binary, which independently confirms the main-tree binary is a valid 133f5ee
control and that the build is reproducible.

## 2. The arms — measured on golden, and on our side, for every cell

Run one with `gold.sh <arm> <outdir> [binary]`. It emits `g.dump`, `o.dump` and
`cmp.txt`, and it **refuses** to reach a verdict if either database is absent
(`uhdm-cmp` exits 0 on a missing input, so an unguarded probe prints PASS on a
run that produced nothing).

| arm | cell | golden verdict |
|---|---|---|
| `a1` | source order vs name order (module container) | **base = NAME-first** |
| `a2` | container = PACKAGE only | prefix `p49b::` → looks doubled |
| `a3` | THREE typedefs, source order fully reversed | **flat, no chaining** |
| `a4` | genuinely different specialisations + a lonely typedef | grouped anyway; lonely gets no alias |
| `a5` | two module containers import the same typedef | one object, parent = one container (see §6) |
| `a6` | container = CLASS | prefix `work@a6_holder::` |

## 3. THE DECIDER: golden uses **NAME ORDER**, not source order

The brief asserted golden mints at the **source-first** typedef and that
`src/ParamEmit.cpp:19047-19049`'s name-order pick only coincidentally matches
the UVM corpus. **That is refuted.**

`a1/dut.sv` (line numbers verified with `awk 'NR>=14&&NR<=16{print NR, $0}'`,
never assumed):

```
line 15:   typedef gc49#(string, int) zzz_first_t;     <- SOURCE-first, name-LAST
line 16:   typedef gc49#(string, int) aaa_second_t;    <- source-second, NAME-first
```

Golden gives **both** objects `line:16:11, endln:16:15` — line **16**, the
**name-first** typedef — and hangs the alias on `zzz_first_t`:

```
\_class_typespec: (p49a::aaa_second_t), line:16:11, endln:16:15     <- BASE, no alias
\_class_typespec: (p49a::zzz_first_t),  line:16:11, endln:16:15
  |vpiTypedefAlias:
  \_ref_typespec: (work@a1_top.p49a::zzz_first_t)
    |vpiActual:
    \_class_typespec: (p49a::aaa_second_t), line:16:11, endln:16:15
```

`a3` settles it beyond argument with source order **fully reversed** (source
`zzz_3_t`, `mmm_3_t`, `aaa_3_t` on lines 14, 15, 16; name order the exact
opposite). Golden's base is `aaa_3_t` — name-first, **source-LAST** — and all
three objects carry `line:16:11`.

Corroboration from a second, independent direction: the comment already in the
tree at `src/ParamEmit.cpp:19036-19039` says "the name-first of the typedefs
that share it". The code and golden agree; the brief's model was the outlier.

**Consequence for pass 50: do not touch the base-selection comparison at
`src/ParamEmit.cpp:19047-19049`. It is correct.**

## 4. Span rule — confirmed and generalised

Golden's span is the **generic-class-name token of the base typedef**, end
column exclusive.

* `a1`: `line:16:11, endln:16:15`; `substr(line16, 11, 4)` = `gc49` (4 chars, 11→14, exclusive 15).
* `a4` lonely: `line:19:11, endln:19:18`; `substr(line19, 11, 7)` = `other49` (7 chars).
* UVM: `29:9, endln:29:17` — `typedef ` is 8 chars so col 9 starts `uvm_pool`, 8 chars, exclusive end 17.

## 5. Container prefix — rule (4) confirmed, and it has a **third spelling the brief did not state**

Golden's `ref_typespec` fullname is **the container's own fullname + a joiner
that depends on the container's kind + the package-qualified typedef name**.
Measured on golden in all three kinds, and on our side in two of them:

| container kind | joiner | golden fullname | ours | arm / test |
|---|---|---|---|---|
| `package` | none (fullname already ends `::`) | `uvm_pkg::` + `uvm_pkg::uvm_id_verbosities_array` | **same** | `a2`, BuildUVMPkg |
| `module_inst` | `.` | `work@top_tb.uvm_pkg::uvm_id_verbosities_array` | `p49a::p49a::…` **WRONG** | `a1`, SeqDriver |
| `class_defn` | `::` | `work@env::uvm_pkg::uvm_id_verbosities_array` | `p49f::p49f::…` **WRONG** | `a6`, SimpleUVM, Scoreboard |

The brief gave the rule as "CONTAINER PREFIX + the PACKAGE-QUALIFIED NAME",
which is right, but it only ever spelled out the **module** (`.`) and **package**
(none) cases. The **class** container takes `::`, and that is **3 of the 7
comparable UVM rows** (SimpleUVM ×2, Scoreboard ×1). A law that only ever saw
one spelling has an unmeasured half; this was that half.

Our code builds the prefix at `src/ParamEmit.cpp:19068`, literally
`prefix + prefix + std::get<0>(pkgClassTd9[i])` — verified by opening the file.
That is accidentally right for a package container and wrong for the other two.

**This difference is `vpiFullName`-only, therefore NOT cmp-visible**
(`BaseClass::Compare` reads VpiType/VpiName/VpiDefName). It is DUMP_MATCH work.

## 6. `a5` — shared vs per-container is **NOT settled**, and here is why

`a5`'s golden publishes the listing under both `work@a5_mod_one` and
`work@a5_mod_two`, but `uhdm-dump` expands a repeated object only once, and the
dump carries no `id:`. The single expansion is parented at `work@a5_mod_two` (the
**last** container). So the evidence *leans* "one object per typedef name,
parented at one container", but **it does not distinguish that from one object
per container**. Do not quote a5 as settling this. Settling it needs an
id-printing probe; `uhdm-cmp` prints ids, `uhdm-dump` here does not.

## 7. THE HEAD — reproduced, and the real defect is narrower than the brief says

The UVM-4 head census on my own binary (`heads.sh`, which counts heads with
`grep -c '^LHS:'` at column 0 and **refuses to print a number it cannot
substantiate**):

```
TEST           MODE      CMPLINES  HEADS HEAD_MD5_IDNORM
BuildUVMPkg    default        50      1 65e682317a01e123ff5385596cf95296
Scoreboard     default        50      1 8b6c80911ce8f982ad68629109109b60
SeqDriver      default        50      1 d0133c2a250ae2f2d7e31eccfdd1a48a
SimpleUVM      default        50      1 94e68124ad8969aa7e5526004601a2ee
BuildUVMPkg    testflags      50      1 65e682317a01e123ff5385596cf95296
Scoreboard     testflags       -      - SKIP-NOFILE   (SLANG_REJECT at baseline)
SeqDriver      testflags      50      1 d0133c2a250ae2f2d7e31eccfdd1a48a
SimpleUVM      testflags      50      1 94e68124ad8969aa7e5526004601a2ee
---- measured=7  skipped=1
```

50 lines and exactly 1 head each, as the brief said. The id-normalised md5 is
**identical across modes per test** and **differs between tests** — the four
share one *law*, not one byte string; the names and containers differ per test.

`a1` reproduces the head's difference **six times** in a 38-line file:

```
class_var (p49a::holder49::hz) -> vpiTypespec -> ref_typespec -> vpiActual:
  GOLDEN: class_typespec (p49a::zzz_first_t), line:16:11, endln:16:15
  OURS:   class_typespec (gc49),              line:19:5,  endln:19:16
```

exactly the corpus shape (`uvm_id_verbosities_array` at `29:9` vs `uvm_pool` at
`62:3`, our object parented at the `class_var`). **So the defect is not in the
typedef *publication*** — in `a1` our published listing matches golden object
for object, base choice and all. The defect is that **a declaration whose type
names such a typedef mints a fresh declaration-site `class_typespec` named for
the *generic class* instead of pointing at the typedef's existing per-name
object.** Fix = point at the existing object, not mint a new one.

Same law one level down, seen in the implementer's **`t49a`** (not `a1` — `a1`
declares `int k; int t;` and so has no type-parameter cell; `t49a` declares
`KEY k; T t;`): golden's `int_var k` points at the `int_typespec` at `12:27`
parented at `type_parameter KEY`, while ours mints a second `int_typespec` at
`13:5` parented at the `int_var` — **and we already emit golden's object too**,
in `weaklyReferenced`. The object exists; the reference points at the wrong one.
`t49a` is kept in `wf_9b349e10-e76-1/tools/probe/r10uvm49repro/t49a/`; its run is
`/tmp/r10uvm49_a`.

## 8. ⚠ `a1` is CMP_EQUAL **while carrying the defect six times**

```
cmp rc=0  cmp lines=0  heads=0     # a1
```

Both `a1` differences are cmp-blind: the fullname one because `Compare` never
reads `VpiFullName`, and the `vpiActual` one because golden's
`class_typespec (p49a::zzz_first_t)` is reached **first** through the container's
`vpiTypedef` list — where it pairs against our identical object and compares
equal — so `m_visited` short-circuits the later visit through `hz`'s
`vpiActual` and returns 0 without ever looking at our `gc49`.

**Do not use `a1` as a pass/fail gate.** It is a *dump* arm. `a1`, `a2`, `a3`,
`a4`, `a5` and `a6` are **all** `cmp lines=0, heads=0` while their dumps differ.
Judge these arms on `diff -u g.dump o.dump`, never on `cmp.txt`.

`diff -u g.dump o.dump | grep -c '^[-+]'`, **minus the 2 `diff -u` file-header
lines** (that convention matters — the raw count is content+2):

| arm | a1 | a2 | a3 | a4 | a5 | a6 |
|---|---|---|---|---|---|---|
| content ± lines | 46 | 18 | 46 | 42 | 34 | 26 |
| raw `grep -c` | 48 | 20 | 48 | 44 | 36 | 28 |

This also explains why the corpus *is* cmp-visible while `a1` is not, and it
names the untested cell that should be arm `a7`: in `a1` the module imports the
package **directly**, whereas SeqDriver has `module top_tb` over `package
adpcm_pkg` which imports `uvm_pkg` — a **transitive re-export**, and golden's
`vpiInstance` is the intermediate package `adpcm_pkg`, not `uvm_pkg`. That is
the most likely reason our published listing diverges there and stops
short-circuiting. **Build the transitive-import arm before writing emitter
code.**

## 9. Shared-object hazard is 16 lines away, not hypothetical

`src/ParamEmit.cpp:19061-19065` mutates `cts9`'s location **in place**:

```
cts9->VpiLineNo(bts9->VpiLineNo());   ... VpiColumnNo / VpiEndLineNo / VpiEndColumnNo / VpiFile
```

and the *same* object for the *same* typedef is registered into both live tables
immediately above, at **19023-19026**:

```
19023   if (!topView)
19024       typedefTs[&ta] = ts;
19025   else
19026       pkgTopTypedefTs[&ta] = ts;
```

There is **no `isSharedAliasTs` call anywhere in 19023-19072**; the nearest call
site in this file is `src/ParamEmit.cpp:20290`. `isSharedAliasTs` is declared at
`include/UhdmExporter.h:3098` and defined at `src/UhdmExporter.cpp:1094`.

## 10. Line-citation audit of the pass-49 brief

Every line below was checked by opening the file.

| brief's claim | verdict |
|---|---|
| `pkgClassTd9` declared at `src/ParamEmit.cpp:16985` | **correct** |
| filled at `:18953` (`pkgClassTd9.push_back({std::string(ta.name), cts9, key9})`) | **correct, exact** |
| base picked by name at `:19047-19049` | **correct** (`if` at 19047, comparison 19048-19049) |
| doubled fullname at `:19068` | **correct, exact** — literally `prefix + prefix + …` |
| `Typedef_alias(art9)` at `:19070` | **correct, exact** |
| "the alias loop at `:19040-19070`" | **off by two** — the block is `19040`–`19072`; two loops, at 19042 and 19052 |
| "`typedefTs`/`pkgTopTypedefTs` are filled at `:17589, :17594, :17596, :17612, :17894, :18006`" | all six **correct**, but the list is **incomplete and omits the load-bearing pair**: there are 13 sites — the six listed plus `18070, 18129, 18218, 18642, 18654, 19024, 19026`. `19024`/`19026` sit **14–17 lines above** the block that mutates those very objects. |
| "golden uses the SOURCE-FIRST typedef … name order is not golden's rule" | **REFUTED** — see §3 |
| "IT IS PARENTED AT THE IMPORTING CONTAINER … and that is the NEW HALF this pass must add" | **already done** — `a1`/`a2`/`a6` show our published objects already carry the container parent and match golden; the new half is the **joiner** (§5) and the **declaration-site mint** (§7) |
| "cmp output is 50 lines each", "all four fail here first", "seven comparable rows" | **all correct** (§7) |

## 11. Gate status

| gate | result |
|---|---|
| build | my worktree, `cmake --build build -j 2`, rc 0 |
| 23 goldens, `SLANG_UHDM` exported to **my** build | `PASS=23 FAIL=0` |
| negative control `SLANG_UHDM=/bin/false` | `PASS=0 FAIL=23` |
| UVM-4, `--mode both` | 7 comparable rows, **all CMP_NOTEQUAL**, 0 conversions |
| `InterfaceModPort`, `BlackParrotComplex`, both modes | `CMP_EQUAL` ×4, dump `differ` — **identical to `results/golden_surelog.csv`** |

The two full corpus sweeps and the byte verifier were **not** run, and that is
deliberate: there is no source change to gate. My binary is byte-identical to
the committed-baseline binary, so every corpus row and every database byte is
unchanged by construction. Spending two sweeps to re-derive a baseline the
repository already holds would not have produced a single new fact.

`results/gate_uhdm2rtlil.csv` and `results/golden_surelog.csv` were **read only,
never rebuilt, edited or included**.
