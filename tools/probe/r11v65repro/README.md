# r11v65 — ADVERSARIAL VERIFICATION of § `unpackedAliasNetType65`, and the ELEMENT-REACH FENCE it needed

Base `785fb3e7` (matrix-1.87). Pins: slang upstream `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 (`~/git-repos/Surelog/build/bin/surelog`, the golden producer),
uhdm2rtlil v0.68. Three binaries, each frozen `555` before any sweep:

| binary | md5 |
|---|---|
| pristine (my own worktree build at `785fb3e7`) | `8090e35ab1057cc7d4b3e0118a39ce47` — **the OPS pin, byte-identical to the main tree** |
| the implementer's law, as shipped in `/tmp/r11u65.patch` | `7dadad859cc42db4887c5658077384c8` — **reproduced bit-for-bit** |
| the law **plus** this verification's fence | `40563d03c6a4c68ed7192f6bd5657f5e` |

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces. The law as shipped also stamps `vpiNetType:36` on **eight distinct
golden cells where golden stamps NOTHING and our pristine emission already
agreed with golden** — AWAY-GOLDEN on legal SystemVerilog, invisible to both
corpora and therefore invisible to the pass's own census. The fence below
removes all eight and keeps every one of the implementer's 35 TO-GOLDEN cells.

---

## 1. WHAT REPRODUCED, BIT-FOR-BIT

* pristine md5 = the OPS pin; law md5 = the reported `7dadad85…`;
* the witness head at the base: `mem_packed_2d_byte_write`, **29 cmp lines, 1
  head (`grep -c '^LHS:'` = 1), in BOTH modes**, head object
  `logic_net: (work@dut.mem)`, the diff carrying `|vpiNetType:36`
  ([evidence/HEAD.base.testflags.err](evidence/HEAD.base.testflags.err),
  [evidence/HEAD.base.default.err](evidence/HEAD.base.default.err));
* `nets::Compare` reads the field —
  `~/git-repos/UHDM/build/generated/src/nets.cpp:277`;
* the ADVANCE: **29 → 24 cmp lines, 1 head, both modes**, the head stepping onto
  r11u52's R2 (golden's folded `constant 3` against our symbolic bound),
  `vpiNetType` gone from the diff, row still `CMP_NOTEQUAL`
  ([evidence/HEAD.fix.testflags.err](evidence/HEAD.fix.testflags.err));
* the implementer's own 13-arm grid, per-arm cmp line counts at the base:
  c1 72, c2 350, c3 15, n1 66, n2 280, n3 29, n4 29, n5 66, n7 164, n8 15,
  x1 66, x2 57 — every one as reported;
* u2r byte movers `mem_packed_2d_byte_write` ×2 with byte sizes
  17051→17053 (testflags) and 22132→22134 (default), the order-blind diff
  being **exactly one line, `> |vpiNetType:36`**, per database.

---

## 2. WHAT BROKE — THE LAW OVER-REACHES THROUGH AN ALIAS

The shipped clause descends the written alias's unpacked levels to an element
and stamps whenever that element's CANONICAL type is a four-state packed
vector or scalar. The canonical type is blind to how many aliases were crossed
to reach it, and to where those aliases live. Golden is not.

Ten verifier arms, one cell per declaration, `surelog -parse -nobuiltin
-nocache -sv` **rc=0 and 0 `[ERR` on every arm**, both our binaries rc=0
(`v7_decl` is a measured FENCE arm: our exporter rejects a `$unit`-scope
unpacked typedef, rc=4, on BOTH binaries). Arm rcs:
[evidence/ARMS.rc.pris.txt](evidence/ARMS.rc.pris.txt),
[evidence/ARMS.rc.fix.txt](evidence/ARMS.rc.fix.txt).

### (a) `v8_alias2` — alias depth × home, twelve cells in one module

| cell | declaration | golden | pristine | law as shipped | with the fence |
|---|---|---|---|---|---|
| d01 | `lv_t d01 [2];` LOCAL single alias + declarator dim | 36 | 0 | 36 | **36** |
| d02 | `lv2_t d02 [2];` LOCAL alias-of-alias + dim | 36 | 0 | 36 | **36** |
| d03 | `lw_t d03 [2];` LOCAL packed-array-of-alias + dim | 36 | 0 | 36 | **36** |
| d04 | `la_t d04;` LOCAL unpacked typedef, single-alias element | 36 | 0 | 36 | **36** |
| **d05** | `lb_t d05;` LOCAL unpacked typedef, **alias-of-alias** element | **0** | **0** | **36 AWAY** | **0** |
| **d06** | `lc_t d06;` LOCAL unpacked typedef, **packed-array-of-alias** element | **0** | **0** | **36 AWAY** | **0** |
| d07 | `cv_t d07 [2];` PACKAGE single alias + dim | 36 | 0 | 36 | **36** |
| **d08** | `cv2_t d08 [2];` PACKAGE alias-of-alias + dim | **0** | **0** | **36 AWAY** | **0** |
| **d09** | `cw_t d09 [2];` PACKAGE packed-array-of-alias + dim | **0** | **0** | **36 AWAY** | **0** |
| **d10** | `ca_t d10;` PACKAGE unpacked typedef, **single-alias** element | **0** | **0** | **36 AWAY** | **0** |
| **d11** | `cb_t d11;` PACKAGE unpacked typedef, alias-of-alias element | **0** | **0** | **36 AWAY** | **0** |
| **d12** | `cc_t d12;` PACKAGE unpacked typedef, packed-arr-of-alias elem | **0** | **0** | **36 AWAY** | **0** |

`d04` against `d10` is the decisive pair: the SAME shape, the alias element
LOCAL in one and PACKAGE-homed in the other, 36 against 0.

### (b) `v9_minimal` / `va_ctx` — one cell per MODULE, so no arm can alias another

`m1`–`m4`, `m7`–`m13` all read golden **0** and pristine **0**; the law as
shipped stamped **36** on every one of them. `m5` (`typedef v a [2]`, element
a single local alias) and `m6` (`typedef v v2; v2 x [2]`) read golden **36**
and are the cells the fence must keep — it does.

`va_ctx` refutes a context hypothesis: declaring the intermediate alias as a
net's own type beforehand (`m9`), afterwards (`m10`) or with its own dimension
(`m12`) does not change the element answer; `x` stays 0 in all three.

### (c) The correction this forces to the landed framing

The implementer's README states, in bold, *"the gate is the WRITTEN FORM, not
the alias's home"*, measured on `n2` `w1`/`e1` (a package typedef whose element
is written `logic [N-1:0]`, reached by wildcard and by explicit import: 36 in
both). **That holds only for an element with no alias in it.** As soon as the
element IS or CONTAINS an alias, the home of THAT alias is a gate: `d04` 36
against `d10` 0, `d03` 36 against `d09` 0. The home test therefore belongs on
the ELEMENT, never on the written name — which is exactly where the fence puts
it, leaving `n2` `w1`/`e1` at 36.

### (d) One cell where golden contradicts itself, recorded not dressed up

`v2_aliaschain`'s `warr` (`typedef v_t [1:0] w_t; typedef w_t wa_t [2]; wa_t
warr;`) reads golden **36**, while the byte-identical shape reads golden **0**
in `v8` (`d06`) and in `v9` (`m1`, alone in its own module) and in `va`
(`m9`/`m10`/`m12`). Three isolated arms against one crowded one: the fence
follows the isolated reading and leaves `warr` at 0 — **STILL-WRONG, never
AWAY**, because pristine was 0 there too.

---

## 3. THE FENCE

`src/EmitHelpers.h`, inside `unpackedAliasNetType65`, after the four-state
element test and before the keyword choice. It walks the element's packed
chain; the first alias it meets must be **module-local** (its parent scope not
a `Package`) and must be **exactly one hop** from an alias-free packed vector
or scalar. No alias on the chain ⇒ accept in every home, which is what keeps
`n2` `w1`/`e1`, `d01`, `d07` and the corpus witness itself.

Nothing else in the patch is touched. The interface def road
(`ModuleEmit.cpp`) calls the same function and inherits the fence.

---

## 4. THE SCORE, WITH THE FENCE

**The implementer's own 13 arms**, re-run on my binaries and scored by net
identity (view × scope × name × net kind):
**TO-GOLDEN 35, AWAY-GOLDEN 0, MOVED-WRONG 0, STILL-WRONG 2** (`ifc_u.uv` =
r10v225 R1, `ss` = the pass's R2) — the implementer's claimed 35/0/0/2,
preserved exactly. Per-arm cmp line counts with the fence equal the report's
law counts cell for cell: c3 45, n3 27, n4 164, n8 16, everything else
unchanged.

**My ten arms** ([evidence/GRID.v.fix.txt](evidence/GRID.v.fix.txt)):
**TO-GOLDEN 36, AWAY-GOLDEN 0, MOVED-WRONG 0.**

New TO-GOLDEN cells the implementer's grid never reached, all confirmed
against golden:

| arm | cell | golden | pristine | fence |
|---|---|---|---|---|
| v1 | `wand v_t nd [2];` | 36 | **2** | 36 |
| v1 | `wor v_t nr [2];` | 36 | **3** | 36 |
| v1 | `tri v_t nt [2];` | 36 | **4** | 36 |
| v1 | `wand a_t wda;` / `wor a_t wra;` / `tri a_t tra;` | 36 | 2 / 3 / 4 | 36 |
| v1 | `wire r_t wrr;` (REG element under a net keyword) | **48** | **1** | **48** |
| v3 | `input pa_t pin` — an **ANSI** port, imported unpacked typedef | 36 | 0 | 36 |
| v3 | `output pa_t pout`, `input pv_t pvin [2]` | 36 | 0 | 36 |
| v4 | `a_t ga;` in an interface reached through a **modport** | 36 | 0 | 36 |
| v5 | `typedef logic signed [1:0] sg_t; typedef sg_t sa_t [D];` | 36 | 0 | 36 |
| v5 | `typedef va_t vaa_t [2];` (unpacked typedef OF an unpacked typedef) | 36 | 0 | 36 |
| v6 | `typedef aa_t loc_t;` re-typedef of an IMPORTED unpacked typedef | 36 | 0 | 36 |
| v7 | `wire v_t nda [2] = '{…}` (net-decl-assign + dim) | 36 | **1** | 36 |
| v7 | `a_t m1, m2;` — two declarators in one declaration | 36 | 0 | 36 |

The `v1` rows are worth naming on their own: **the law fires before
`netTypeFor`'s net-keyword switch, and golden agrees** — a `wand`/`wor`/`tri`
net declared through a vector typedef prints the typedef's keyword (36/48), not
the net kind, while the same net with NO typedef keeps its kind (`wand [N-1:0]
wnp [D]` = 2, unchanged by the fence).

Residues my arms add, each STILL-WRONG and each pre-existing (pristine and
fence identical):

* **V-R1** `w_t wnod;` (a packed-array-of-alias typedef, NO dimension) —
  golden **36**, ours **0**. The landed `aliasOfAlias0` guard in `ModuleEmit`'s
  def-view net loop zeroes it. v2 `wnod`, v8 `d15`, va `m9`/`m10` `wd`.
* **V-R2** `v_t [1:0] sel [2];` (a packed dim written ON the alias) — golden
  **36**, ours **0**; the written form is an `IdentifierSelectName` and the
  stripped type is a `PackedArrayType`, not an alias.
* **V-R3** `cv2_t d16;` (a PACKAGE alias-of-alias, no dimension) — golden
  **0**, ours **36**; the dimension-less def-view arm already over-stamps here.
* **V-R4** an interface's `wire v_t gw [2];` / `wand v_t gd [2];` — golden
  **36**, ours **1** / **2**: the interface def road never consults
  `netTypeFor`'s def-view arm at all, so the net keyword wins there.
* **V-R5** our exporter rejects a `$unit` (compilation-unit) unpacked-array
  typedef outright, rc=4 — `v7_decl`, both binaries.

---

## 5. RE-RUNNING

```bash
bash vrun65.sh <binary> pris          # golden + a binary per arm, BOTH rcs
bash vrun65.sh <other-binary> law
bash vscore65.sh                      # golden vs pris vs law, per net identity
python3 nettype65.py <a-uhdm-dump>    # the SHAPE LISTER: one line per net,
                                      # view|scope|name|kind|NT, backlinks skipped
```
