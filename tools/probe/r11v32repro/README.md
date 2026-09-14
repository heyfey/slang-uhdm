# r11v32 — adversarial verification of r11u32 (the named-type declaration's two halves)

Verdict: **ACCEPT-WITH-FIX.**  r11u32's three laws are correct as decoded and
its four conversions reproduce bit-for-bit, but law B (`emitTypeParamArrayVar`)
fires on a **2-state** type parameter, where golden carries no packed array
object at all.  That is a pristine-right → patched-wrong regression on legal
SystemVerilog, invisible to both corpora.  The fix is one predicate and moves
no corpus database; `/tmp/r11u32.verified.patch` carries it.

Everything below was measured on this verifier's own builds at `b44b24b1`.
Binaries (frozen, `chmod 555`, every `cmds.txt` audited by path):

| binary | md5 |
|---|---|
| pristine `b44b24b1` | `0fc7b2ec16a79f41b5bc73ef10275de1` (the pin; byte-identical to the main tree) |
| r11u32 as submitted | `5de09f4c516a1d7a01a6471153420dac` (matches the implementer's own figure) |
| verified (r11u32 + the fix) | `c66b1f2c7d7b79c99b6be48177af002e` |
| pristine `c731550c` (HEAD) | `723cb6db14308de6a257e5c3bfd45f8f` |
| verified on `c731550c` | `eb63e166e8f297649e0cf6371e4f2be4` |

---

## 1. What reproduced

* both binaries rebuilt from scratch; the pristine md5 **is** the pin, and the
  patched md5 **is** the implementer's — so the two measurement environments
  are the same environment;
* `tests/check_goldens.sh` 23 PASS / 0 FAIL on pristine, on r11u32, on the
  verified binary and on the verified binary built at HEAD; `SLANG_UHDM=/bin/false`
  0 PASS / 23 FAIL (the negative control that proves the export is read);
* uhdm2rtlil **768 → 772 CMP_EQUAL / 36 → 32 CMP_NOTEQUAL in each mode**, and
  the whole-row diff over both modes contains **exactly** the four claimed
  conversions and nothing else (`evidence/rows.txt`);
* this verifier's own PRISTINE uhdm2rtlil sweep is byte-identical to the
  committed baseline (`ct8rows` PASS), so the baseline is the right ruler;
* surelog corpus **474/9 default, 469/8 testflags, unmoved**; the only
  whole-row differences between the pristine and patched sweeps are two
  `SURELOG_FAIL` detail strings that embed the workdir path;
* uhdm2rtlil byte movers **12 / 1608** (6 per mode) — `arb_idx_cast`,
  `gen_scope_numports`, `latch_packed_enum_loop`, `packed_array_reset_loop`,
  `param_name_collision_typeparam`, `struct_member_cfg_width` — with SELFCHECK
  1607/1608 as the positive control;
* an INDEPENDENT source-level predictor (`predict.py`, a deliberate superset:
  no elaboration, no ANSI test) names 19 candidate designs from the sources
  alone; **every one of the 6 movers is inside it** and no mover lies outside
  (`struct_member_cfg_width` matches the law-C shape but escapes the
  predictor's own `typedef` regex, which stops at the first `;` inside a
  multi-line struct — stated as a limitation of the predictor, not a miss of
  the law);
* the two non-converting movers each moved their head OFF this family:
  `arb_idx_cast` `logic_net(work@dut.index_nodes)` → a def-view `gen_for`
  `operation`; `struct_member_cfg_width` `ref_typespec(…fu_data_i)` → a
  `param_assign` `constant`.  One head per run in every measurement;
* protected databases, by name and by md5, identical across pristine and
  patched: SVSwitch `4842211c4030`, YosysVerx `6ccda350c24a`,
  InterfaceModPort `59a365f3ce2c`, Earlgrey_0_1 `59d0ee6d10c3` (testflags) /
  `8bdf25272e08` (default), BlackParrotComplex and YosysOldOr unchanged in both
  modes;
* canaries `ok=51 changed=1` (surelog) / `ok=8 changed=0` (u2r), `ctcan2` PASS
  on both corpora, `canaudit` `audited=29 UNCOVERED=0 FENCE-BREACH=0`;
* the one `changed` canary — `Earlgrey_0_1,testflags,CMP_EQUAL/differ ->
  CMP_EQUAL/` — reads **identically on this verifier's PRISTINE sweep**, which
  settles it: it is the uhdm-dump timeout draw, not the patch.  Status
  unchanged, and the database byte pin holds exactly;
* surelog byte movers **6 / 960** (the implementer reported 5; testflags
  SeqDriver is the sixth), all UVM coin: order-blind, path-normalised,
  sorted dumps differ by **0 lines** (Scoreboard/default) or the documented
  **4-line** `UINT` + `vpiDecompile` line-number pair.  POSITIVE CONTROL: the
  PRISTINE binary run twice on MiniAmiq/default with the sweep's own argv
  produced two further databases, giving **four distinct hashes for one binary
  on one input** (`evidence/uvm_coin.txt`);
* the patch applies clean on a fresh `b44b24b1` and on `c731550c`, rc 0, zero
  conflict markers, no `results/*.csv` edit, fence names 0/0/0/0.

## 2. What broke — and the fix

`evidence/regression_witness.txt` carries it in full.  In one line: a
`parameter type` bound to a **2-state** vector or scalar carrying a packed
dimension (`parameter type T = bit [7:0]; T [1:0] d;`) elaborates in golden as
a flat `bit_var`; r11u32 emits a `packed_array_var`.  Pristine was RIGHT.
Three minimal designs go `CMP_EQUAL → CMP_NOTEQUAL` under the official judge
(`w1_regression_witness.sv`, `g03_tp_bitscalar_pk`, `g05_tp_ovr_2state`), and
six grid arms move away.  `g05` is the one that fixes the gate's shape: its
parameter's written default is 4-state and only the OVERRIDE is 2-state, so the
test must be asked of the resolved canonical leaf.

`§ typeParamArrayVarIsFourState32v` — `if (!leafCt.isFourState()) return nullptr;`
in `emitTypeParamArrayVar`, immediately after the existing kind test.  With it:
0 regressions over 44 purpose-built designs, AWAY 0 on the 179-arm grid, and
**MOVERS 0 / 1608** against r11u32-as-submitted on the uhdm2rtlil corpus — so
every corpus number the implementer measured carries over verbatim.

## 3. The instruments (all measurement-only; the judge is uhdm-cmp)

| file | what it is |
|---|---|
| `gengrid.py` → `vgrid.sv` | 179-arm adversarial grid: name kind × dims{none, packed, 2×packed, unpacked} × position{body, input, output, **inout**}, with the faces r11u32's grid does not carry — a type parameter bound to a **2-state** vector, to a 2-state **scalar**, to a **typedef**, to a **signed** vector, and **overridden at the instance** as well as defaulted; package **enum** and **struct** typedefs named unqualified and scoped; a `reg`-written typedef; a typedef **of** a type parameter |
| `gridread.py` | an independently written DEF/ELAB reader (not derived from the implementer's), calibrated golden-vs-golden to **0 DEF-DIFF / 0 ELAB-DIFF** on all 179 arms |
| `mkfaces.py`, `mkfaces2.py`, `face.sh` | 44 one-face designs, each its own tiny compile, scored by the OFFICIAL `uhdm-cmp` on both binaries with every rc recorded — the instrument that turns a grid cell into a verdict |
| `toaway.py` | location-blind TO-GOLDEN / AWAY-GOLDEN / STILL multiset scorer per mover |
| `predict.py` | a-priori mover prediction from the corpus SOURCES alone |

## 4. Residues this verification adds (each pinned by a grid cell or a face)

* **`y_tdtp_*`** — a module-local typedef **of** a type parameter
  (`typedef T ali_t; ali_t [1:0] d;`).  Golden: DEF no `vpiNetType`, ELAB a flat
  `logic_var`.  Ours: DEF `36`, ELAB `packed_array_var`.  PRE-EXISTING (both
  binaries), and it is law A's blind spot — the leaf alias is a
  `TypedefDeclaration` whose *target* is the `TypeAssignment`, so neither the
  syntax test nor the enum test sees it.  Face `f09_typedef_of_typeparam_pk`.
* **`y_tdr_pk_net`, `y_tdr_pk2_net`** — a `reg`-written typedef carrying a
  packed dim: golden's ELAB view is a flat `logic_net`, ours a
  `packed_array_var`.  PRE-EXISTING, no arm of the implementer's grid.
  Face `f13_regtypedef_pk`.
* **`y_tdr_unp_net`** — the same typedef with an UNPACKED dim: golden DEF
  `vpiNetType 48` (`vpiReg`), we print none, and the ELAB view is `array_net`
  in golden against our `array_var`.  Same family as the implementer's R2, one
  keyword over.
* **`y_pkeq_pk_{in,out,io}`, `y_pkeq_pk2_*`** — confirms the implementer's R1
  (a packed-dim SCOPED package typedef at a port) and extends it to the
  **inout** position and to two packed dims.
* **`y_tps_*`, `y_tps_nod_net`** — confirms R0 (struct-bound type parameter:
  golden `struct_net`/`packed_array_net`, ours `struct_var`/`packed_array_var`)
  at every position including inout.
* **`f07_tp_pk_iface`** — the SAME packed-dim type-parameter declaration inside
  an **interface** body (`interface itf #(parameter type T = logic [7:0]) ();
  T [1:0] d; endinterface`).  Golden's elaborated view is a `packed_array_var`;
  ours is still a flat `logic_var` after the patch — law B's call site sits in
  the module signal loop and never runs for an interface body.  A MISS, not a
  regression (the row is NOT-EQUAL before and after, and its head merely moves
  from a def-view `logic_typespec` face onto this one).  The nearest neighbour
  of the four conversions, and the cheapest next cell on this road.
* **`f34_k9_iface_typearg`** — slang refuses `cannot instantiate a module in an
  interface`, so the law-C interface cell has no arm on our side at all
  (SLANG_REJECT on both binaries; out of scope by the standing decision).
* **`g01_tp_int_pk`, `g02_tp_integer_pk`** (`parameter type T = int; T [1:0] d;`)
  produce `[ERR:UH0703] Internal Error: adding wrong object type (int_var) in a
  enum_struct_union_packed_var_group group!` in Surelog v1.87 — surelog rc 4.
  NO GOLDEN EXISTS for that cell; both binaries were scored on it and both
  disagree with the partial database.  Recorded so no later pass mistakes the
  arm for a law.
