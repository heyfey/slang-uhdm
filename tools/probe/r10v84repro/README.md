# r10v84 — ADVERSARIAL VERIFICATION of r10earl84 (§ `connHpIpsBaseNonOvParamFold84`)

**VERDICT: ACCEPT-WITH-FIX.** Every headline number in the implementer's report
reproduces **bit for bit** from an independent build (both binary md5s hit).
One **RIGHT→WRONG regression on legal SystemVerilog** was found by the arms and
fixed here: a **`bind` instantiation**. Ship `/tmp/r10earl84.verified.patch`.

**MEASUREMENT-ONLY directory.** `~/git-repos/UHDM/build/bin/uhdm-cmp` stays the
sole acceptance judge. BASE `0f32387`, branch `auto5h`. `results/*.csv` READ
ONLY and untouched — **NO ROW CONVERTED**. slang NOT patched.

---

## 1. What was reproduced, independently

Fresh worktrees `/tmp/wt_v84pris` and `/tmp/wt_v84` at `0f32387`, both
configured and built from scratch (`-j 2`), both binaries frozen `r-xr-xr-x`
before any sweep, `SLANG_UHDM` exported explicitly per binary, every `cmds.txt`
audited by binary PATH.

| claim | implementer | this verifier |
|---|---|---|
| pristine binary md5 | `c5393d4b65932e92fb79410dacd93409` | **same** |
| as-submitted binary md5 | `67a552d510013eef8aa4a3f78b682c9c` | **same** |
| goldens | 23/0, negative control 0/23 | **same** |
| uhdm2rtlil both modes | 679 / 50 / 2 | **same** |
| surelog default | 471 / 283 / 25 / 10 / 5 | **same** |
| surelog testflags | 466 / 284 / 23 / 9 / 5 / 3 / 2 / 1 / 1 | **same** |
| ct8rows, 4 comparisons | 0 differing rows | **same (PASS ×5)** |
| `cmds.txt` audit | 3035 files, 54 without a slang line, symmetric | **same** |
| byteverify u2r | MOVERS 0 / 1358, SELFCHECK 1357 | **same** |
| byteverify surelog | MOVERS 2 / 956 | **3 / 956** — the two predicted Earlgrey DBs **with the identical hashes**, plus the documented **Scoreboard/default COIN** (order-blind sorted-dump diff **0 lines**, unsorted 92 — the svunit_pkg `vpiTaskFunc` order flip; its row stays CMP_EQUAL) |
| mover hashes | `2a0b5eda6b19`/`eca4492a7f16`, `469400b3a877`/`3d2354c0922c` | **same** |
| A/B gate `R10E84_OFF=1` on Earlgrey | reproduces pristine byte for byte, both modes | **same, re-run here** |
| heads | 240→214 / 268→144, one head each, 10 other rows byte-identical | **same**; `HEAD_AFTER_*` reproduce the committed logs with **0 differing lines** modulo object ids |
| canaries / ctcan2 / canaudit | ok=52, ok=8, PASS, PASS, `audited=29 UNCOVERED=0 FENCE-BREACH=0` | **same** |
| protected DBs | 5 names SAME, SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a` | **same** |
| census FAMILY-HP / FAMILY-BARE / FOLD-ELSEWHERE | 6 / 0 / 0 (surelog), 0 / 0 / 0 (u2r) | **same, the same six cells** (flash_ctrl.sv 171/249/277 × 2 modes) |
| golden's own kept refs in an ELAB High_conn bound | 2352 `i`, 24 `LsbAddrBit`, 4 `usb_in_endpoint`, 2 `sel`; **no ips-BASE `ref_obj`** | **same, both corpora** |
| Earlgrey fixed-universe re-score | BOTH-SAME 8171→8183, MOVED-WRONG 30→18, GOLDEN-ONLY 30, OURS-ONLY 3422, FAMILY-HP 6→0 | **same** |
| R1 (the 18 residual MOVED-WRONG) | all `SLOT=WIDTH` ips at 82:46 / 83:50 / 85:51 / 87:51 / 89:41 / 108:34 | **same, exactly** |
| the four shipped arms | S→S 118, W→R 58, **R→W 0**, W→O 0, W→W 30 | **same, exactly** |
| wide boundary | LISTED=PROCESSED, identical 7202, no_output 294, rc histogram symmetric, rc=139 14/14 same files | **same** (LISTED=PROCESSED=3758 here, +5 verifier arms; identical 7202, no_output 294, rc 0/3/4/139 = 6923/280/299/14 per side) |
| R5 (`r10buvm22repro/g22.sv`) | not this law's; the value tracks the binary's code layout | **confirmed independently**: `R10E84_OFF=1` prints the patched number; pris `…433`/`…577`, pat `…465`/`…609`, +32 each, and the patched image is 544 bytes larger |

**Two evidence discrepancies, neither material.** (i) The pass README says the
repro dir holds *26 files*; it holds **29**. (ii) My `--only-porthc` census of
the surelog corpus finds **46** databases holding a port-connection select, not
42 (and correspondingly BOTH-SAME 85384, GOLDEN-ONLY 1884, OURS-ONLY 5437). The
**decision-relevant** figures — FAMILY-HP 6, FAMILY-BARE 0, FOLD-ELSEWHERE 0,
MOVED-WRONG 30, and the identity of the six cells — reproduce exactly, and my
count is a superset, so the prediction is unaffected.

---

## 2. THE REGRESSION — § `connBindInstKeepsRef84v`

`v5_bind84.sv`, 21 lines of legal SystemVerilog, both binaries and Surelog at
`rc=0`:

```systemverilog
module bnd84 (input logic [7:0] a);
endmodule
module bindee84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Bd = 2;
endmodule
module top5_84;  bindee84 u_be ();  endmodule
bind bindee84 bnd84 u_bind (.a(reg2hw.addr.q[Bd +: 8]));
```

| | golden | pristine | as submitted |
|---|---|---|---|
| ips `Base_expr` | `ref_obj Bd` | `ref_obj Bd` | `constant UINT:2 sz32 ct9` + `int_typespec(signed)` |
| `hier_path VpiName` | `reg2hw.addr.q[Bd+:8]` | `reg2hw.addr.q[Bd+:8]` | `reg2hw.addr.q[2+:8]` |

**pristine == golden; the patch as submitted moves both cells away.**
`RIGHT→WRONG = 2` — the only two on 12 arms.

### The decode (Surelog, not guessed)

`DesignElaboration::createBindInstance_` (`DesignElaboration.cpp:652-654`):

```cpp
instance = factory->newModuleInstance(targetDef, fC, bind->getStmtId(),
                                      parent->getParent(), instName, bindModName);
...
instance->setInstanceBinding(parent);
```

The bind instance is parented at **`parent->getParent()`** — the scope
*enclosing* the bind target — and the target is recorded only as the
`InstanceBinding`. `NetlistElaboration::high_conn_`'s `Reduce::Yes` recompile
(`NetlistElaboration.cpp:1332-1337`) therefore evaluates the actual in that
*enclosing* instance, where a parameter of the TARGET module has no stored
`Value`; `instance->getValue(name)` returns null, no substitution happens and
the `ref_obj` survives. The signal still binds, through the separate
`bind_net_(…, instance->getInstanceBinding(), …)` path at
`NetlistElaboration.cpp:1419` — which is why the *net* resolves while the
*value* does not. The census key confirms the parenting from the data: golden
puts the bind instance at `work@top5_84.u_bind`, not under `u_be`.

### The fix, and why it is exactly this narrow

`v6_bind2_84.sv` measures all three positions of the bind family:

| cell | shape | golden | verdict, as submitted | verdict, FIXED |
|---|---|---|---|---|
| `b1` | the **bind instance's own** High_conn, base = the TARGET's localparam | keeps `ref_obj` | **RIGHT→WRONG** | SAME→SAME |
| `b2` | a module instantiated **INSIDE** the bind module, base = the bind module's own localparam | **folds** (`UINT:3` + `int_typespec`) | WRONG→RIGHT | WRONG→RIGHT |
| `b3` | the ordinary, non-bind instantiation of the same module | folds | WRONG→RIGHT | WRONG→RIGHT |

So the fence is on **`InstanceFlags::FromBind`** — the bind instance itself —
and deliberately **not** on `ParentFromBind`: a child of a bind instance is an
ordinary child of an ordinary instance and golden folds it. That is the Surelog
decode read back out of the measurement.

Three lines of production, all inside the existing law:

* `include/UhdmExporter.h` — `bool connFromBind84 = false;` with the law.
* `src/ModuleEmit.cpp` — `ConnFromBindGuard84` set beside `ElabConnGuard21`
  from `inst.body.flags.has(slang::ast::InstanceFlags::FromBind)`.
* `src/ExprEmit.cpp` — `!connFromBind84` in the call-site gate, plus fence
  **(g)** in the law block.

`b1`'s `WIDTH` twin moves back with it (the hier_path `VpiName` follows through
§ `hpNameBareIdxFold69`), so the fix restores **2** cells and touches nothing
else: on the seven verifier arms and the four shipped arms the FIXED tallies are
identical to the as-submitted ones **except** `v4` (R→W 2→0), `v5` (R→W 2→0)
and `v6` (R→W 2→0). The wide boundary agrees: with the fixed binary
`v4_ctx84.sv` and `v5_bind84.sv` drop out of the DIFFERING list entirely.

---

## 3. Breaking the law — the arms that did NOT break it

`varm84.sh` / `varm3_84.sh` build each arm with Surelog (`-parse -nobuiltin
-nocache -d uhdm`) and with the frozen pristine / as-submitted / FIXED
binaries, census all four with the implementer's `ct84cen --inst`, and keep the
raw path-normalised `uhdm-dump` as an independent second reading. `vscore84.py`
/ `vscore3_84.py` are the verifier's own multiset scorers; the payload carries
no span-derived field.

| arm | what it breaks | S→S | W→R | **R→W** | W→O | W→W |
|---|---|---:|---:|---:|---:|---:|
| `v1_homes84.sv` | HOMES: module scope, gen-for, gen-if, **nested gen**, gen-case, a hier_path rooted at an **interface instance**, a `program` reader | 16 | 12 | **0** | 0 | 2 |
| `v2_types84.sv` | DECLARED TYPES the shipped grid did not hold: `typedef int`, `typedef bit signed`, `typedef byte`, `reg signed`, a **scalar** `logic signed`, **2-dim packed** signed and unsigned, `bit`, `time`, a **71-bit** vector, value 0 | 22 | 18 | **0** | 0 | 4 |
| `v3_shapes84.sv` | hier_path **depth 2 and 4**, an **instance ARRAY**, a **positional** connection, bare `-:`, a ternary, a concatenation, and **both nestings** of a user call and a system call | 20 | 16 | **0** | 0 | 6 |
| `v4_ctx84.sv` | a **hierarchical** parameter read, an **interface** parameter, an **enum constant**, a declaration range bound, a part_select bound, **a `bind`** | 14→**16** | 0 | **2→0** | 0 | 2 |
| `v5_bind84.sv` | the bind regression, minimised | 0→**2** | 0 | **2→0** | 0 | 0 |
| `v6_bind2_84.sv` | the bind FAMILY: bind instance / inside the bind module / plain | 4→**6** | 4 | **2→0** | 0 | 0 |
| `v7_more84.sv` | a nested module, two instantiation levels, an **operation-initialised** localparam | 8 | 6 | **0** | 2 | 0 |
| `v8_defparam84.sv` | a **`defparam`**-overridden parameter and its control | 2 | 3 | **0** | 1 | 0 |

(`x→y` = as-submitted → FIXED.) **With the fix, `RIGHT→WRONG` is 0 on every
arm, and `WRONG→OTHER` is 0 except the two characterised residues below.**

What survived the attack, and is therefore now measured rather than assumed:

* every generate home folds, and golden folds them all;
* the **signedness model is right well past the shipped grid** — a `typedef` to
  `int`, a `typedef` to `bit signed [3:0]`, `reg signed [7:0]`, a scalar
  `logic signed` and a 2-dimension packed signed vector all land on golden
  exactly, and the unsigned members of the same families land bare;
* the **call-argument fence is right in both nestings**: `uf($unsigned(x))`
  and `$unsigned(uf(x))` both keep golden's `ref_obj` (depth 2, sysCall 1);
* a **part_select** LEFT/RIGHT bound and a declaration range bound stay put
  (`compilePartSelectRange`'s `Reduce::No`);
* an instance ARRAY's per-element High_conns fold and land on golden, while the
  **array-level** cell (`PORTPAR=module_array`), where **golden itself holds a
  `ref_obj` at an ips BASE**, is untouched on both sides — the one corpus-shaped
  near-miss, and it is safe because that High_conn is not emitted through this
  call site.

---

## 4. Residues this verification adds (ranked)

* **R-A `defparam` is an override producer fence (e) does not catch.**
  `v8_defparam84.sv`: golden gives a `defparam`-overridden parameter the
  OVERRIDE encoding (`sz64 UINT:5`, **bare**), exactly like a named `#(.P())`
  override, but `isOverriddenParam` does not see a `defparam`, so the law folds
  it at the DECLARED width with the signed `int_typespec`. WRONG→OTHER, never
  RIGHT→WRONG (pristine held a `ref_obj`, which is also wrong). 0 corpus cells.
  Cheapest completion: route a `defparam`-overridden parameter to
  § `ovHopOverriddenKeepsValue80`'s encoder, or refuse it.
* **R-B a parameter Surelog could not value is SUBSTITUTED BY ITS EXPRESSION,
  not by a reference.** `v7_more84.sv` `u_op`
  (`localparam int Op = ~(('h1 << 3) - 1'b1) & 32'h7`): golden's ips base is the
  whole **`operation`**, unreduced — the same shape as the R0 head. Under
  `Reduce::Yes` an identifier with no stored `Value` gets its default
  EXPRESSION inlined. We fold it to `constant UINT:0` (the arithmetically right
  value). WRONG→OTHER, a kind mismatch either way. **This is a datum R0 needs.**
* **R-C a hier_path ROOTED AT AN INTERFACE INSTANCE never reaches the call
  site.** `v1_homes84.sv` `h_ifpath` (`u_if.reg2hw.addr.q[Db +: 8]`): golden
  folds the base, we keep the `ref_obj` on both sides. A live WRONG→WRONG the
  law does not reach because that hier_path is built elsewhere; the same is
  true of the ARRAY-level `module_array` High_conn.
* **R-D a scalar `bit` localparam.** `v2_types84.sv` `V08`
  (`localparam bit V08 = 1'b1`): golden folds to `SZ=1 BIN:1 ct3 dec"1'b1"`;
  `adjustCopiedParamConst64` refuses. Same family as R7 in `PREDICT_R0.txt`.
* **R-E a `> 64`-bit vector.** `V10` (`logic [70:0]`): golden folds at
  `SZ=71 INT:2`; F-A2 refuses. Known.
* **R-F cosmetic — a leaked `ref_obj` per fold.** The call site emits the base
  and then REPLACES it, so the discarded `ref_obj` stays in the serializer's
  factory and is written to the `.uhdm` file. It is unreachable from the design
  tree (the arm dumps show `ref_obj` objects 67 → 61 and **no** new ones), so
  no generated `Compare` can see it; it costs a few bytes per fold. Fixing it
  would mean testing the fold BEFORE emitting the base, which would break
  fence (b) — leave it.
* **A committed law comment was wrong and is corrected in this patch.** The
  shipped decode said "`integer`, `byte`, `shortint`, `longint` **and a
  typedef** therefore NEVER carry the typespec". The shipped grid's own `ls_t`
  row contradicts it, and so do `v2`'s `V01`/`V02`: a typedef RESOLVES to one
  of `valueRange`'s three kinds, so a signed typedef DOES carry the bare
  `int_typespec` — which is why the code asks `getCanonicalType()`. The code
  was right; only the comment was wrong.

---

## 5. Files

| | |
|---|---|
| `varm84.sh` | one arm, three databases (golden / pristine / patched), rows **and** path-normalised dump |
| `varm3_84.sh` | one arm, **four** databases (adds the FIXED binary) |
| `vscore84.py` | the verifier's 3-way per-cell verdict, multiset join |
| `vscore3_84.py` | the 4-way verdict — as-submitted and FIXED side by side |
| `v1_homes84.sv` … `v8_defparam84.sv` | the eight adversarial arms |
| `VERIFIED.r10earl84.txt` | the full reproduction log and the fixed battery |
