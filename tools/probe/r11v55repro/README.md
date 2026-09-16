# r11v55 — ADVERSARIAL VERIFICATION OF r11u55 (ROAD E: the elaborated
# cont_assign's constant-reducing Rhs is substituted per instance)

Verdict: **ACCEPT-WITH-FIX.** Every headline number in the implementer's
report reproduces bit-for-bit from binaries built here, and the row it claims
CONVERTS does convert in both modes. One cell of the law over-fires on legal,
compilable SystemVerilog where the pristine binary agreed with golden; §
`caStructParamPatternSubstCastFence55v` narrows it, and the narrowing is a
measured corpus no-op.

## 1. What reproduced

| claim | reproduced here |
|---|---|
| pristine md5 `490c201cceef32cff72cfd7192df9396`, byte-identical to the main tree | yes |
| law md5 `0ae83e6a68ff28835665185e522f14a8` | yes, from a fresh 455f226d worktree |
| goldens 23/0, `/bin/false` 0/23 | yes |
| witness head: golden `constant` @18:34–18:35, `vpiDecompile:3 vpiSize:32 UINT:3 vpiConstType:9`, parent cont_assign @40:10; ours `hier_path (CFG.n)` @40:19 | yes, both modes |
| residue 303 golden-only / 19 ours-only (golden 3204/2694, ours 2920/2410) | yes, both modes |
| row CONVERTS: `uhdm-cmp` rc=0, heads=0, 0 cmp lines | yes, both modes |
| residue after the law: 213 golden-only / 19 ours-only | yes, both modes |
| u2r 784→785 CMP_EQUAL / 20→19 CMP_NOTEQUAL, one differing row per mode | yes |
| surelog 474/9 + 469/8 unchanged | yes |
| byteverify u2r MOVERS 2/1608, SELFCHECK 1607/1608 | yes |

Every `cmds.txt` was audited by binary PATH: 1742/1742 per u2r workdir,
1531/1531 slang invocations per surelog workdir, all naming the frozen
`chmod 555` copy for that arm; no main-tree leakage. Every arm's rc recorded.

## 2. The finding — § `caStructParamPatternSubstCastFence55v`

`structParamPattern55` walked the parameter's initializer chain through
`ExpressionKind::Conversion`. `stripImplicitConv` already removes slang's
IMPLICIT conversions, so that hop removed only EXPLICIT casts.

Grid `vv9_cast2`, both binaries rc=0, legal SV:

```
module dut ...
  leaf                            u_p (...);           // control
  leaf #(.C(p::cfg_t'(p::OTHER))) u_c (...);           // cast at the override
```

| instance | golden ELAB | pristine ELAB | law ELAB |
|---|---|---|---|
| `u_p.o_n` | `constant 12`@10:33 | shares the def object | `constant 12`@10:33 (agrees) |
| `u_c.o_n` | **shares the def object** | **shares the def object** | **`constant 31`@11:33** |
| `u_c.o_h` | **shares the def object** | **shares the def object** | **`constant 16'h00EF`@11:40** |

Read off the databases, not the lister: golden's and the pristine binary's
elaborated `u_c` cont_assigns carry no `vpiRhs` child at all; the law binary's
carry a folded constant. Golden's `writeCont_assign` reduce DECLINES when a
cast stands between the read and the pattern — the producer's own table, not
SystemVerilog's constant folding. That is pristine-right → patched-wrong.

The fix deletes the Conversion hop. It can only turn a substitution back into
the pristine share; it never widens. Arm `vv1c_cast` shows golden declining
the same way for a cast-written package localparam (that arm is not a valid
cell: our emitter rejects the source with rc=4, `expression kind: Invalid`).

Measured effect of the fix: **4 cells across 3 arms change, all of them back
to golden; 0 other cells change.** On uhdm2rtlil the fixed binary is
byte-identical to the law binary — `byteverify fix vs law: MOVERS 0/1608` —
and still converts the witness with the same mover hashes.

## 3. The grid cut here (11 arms beyond the pass's six)

* `vv1a_pos`, `vv1b_repl` — POSITIONAL and REPLICATED pattern forms. Golden
  folds the positional one (`constant 3`@4:28); we decline (the predicate
  tests `StructuredAssignmentPattern` only). Golden declines the replicated
  one and so do we. No regression; residue R4 below.
* `vv1c_cast` / `vv1_typeset` — cast-written package localparam; our emitter
  rejects the source (rc=4), so the cells are not measurable at this pin. A
  TYPE-key pattern (`'{u32_t: 7, …}`) was cut and DROPPED: Surelog v1.87
  rejects it outright (`[ERR:UH0712] Undefined pattern key`).
* `vv2_chain` — the W1 hop pushed across two instance boundaries
  (`mid #(.PCFG(p::LIT3))` → `leaf #(.CFG(PCFG))`) and through a module
  localparam. **All six cells identical to golden**: the hop reads the
  instance's effective value, never a declared default.
* `vv3_default` — one `defaultSetter` expression, three member widths, plus a
  negative value on a signed member. **Two divergences, residues R1 and R2.**
* `vv4_singleread` — the `adjustSize` table with the SHARING confound removed
  (each member read exactly once, by a narrower / equal / wider Lhs).
  **All 12 cells identical to golden; the arm converts, rc=0 heads=0.** This
  is what `ve6_adjust_table` could not show: its three-reads-per-member shape
  measures golden's last writer, not `adjustSize`.
* `vv5_deepmulti` — W2 crossed with multi-instance and override, including an
  intermediate member set by a REFERENCE (`sub: p::IN2`) and an inline nested
  pattern at the instantiation. **All 12 cells identical to golden.**
* `vv6_edge` — a 96-bit member (identical to golden), an X/Z literal
  (identical), an ENUM member (**residue R3**).
* `vv7_gensubst` — the blast radius INSIDE the pristine arm (`§
  structParamSetter`'s own shape, re-sized by W3): the corpus widths
  (1-bit member onto 1/2/32-bit Lhs) and the shrink/mask directions. No cell
  moves away; two move toward golden.
* `vv8_sharemut` — "clone, never share" at the mutation site: one package
  literal read by three definitions at three Lhs widths plus a second instance
  of one of them. **All 8 cells identical to golden; the arm converts.** The
  in-place `VpiSize`/`VpiValue` rewrite does not reach a shared object.
* `vv9_cast2` — the finding above.

## 4. Residues measured here and DECLINED (ranked)

* **R1 — `default: '1` plants an UNSIZED constant.** `vv3_default`: for
  `localparam ones_t ONES = '{default: '1}` read onto 8/16/32-bit Lhs, golden
  substitutes `UINT:4294967295 vpiSize:32` and we substitute `'1` with
  **`vpiSize:-1`**, `vpiConstType:3`. The `vpiBinaryConst` arm of the W3 block
  resizes only when SHRINKING and `-1 > 32` is false, so the unsized size
  survives. The law binary's database carries 6 `vpiSize:-1` objects where the
  pristine one carries 3 and golden 1. Pristine was also not-equal here (it
  shared the def object), so this is not a regression — but an unsized
  constant is not an object the producer ever plants at a cont_assign Rhs.
  The cheap fence is at the predicate: decline when the setter is an
  unbased-unsized literal.
* **R2 — a negative value on a signed member changes encoding.**
  `vv3_default`, `NEG = '{s: -1, …}` read onto `logic signed [31:0]`: golden
  `vpiDecompile:-1 vpiSize:32 vpiConstType:7`; ours
  `vpiDecompile:4294967295 … vpiConstType:9`. The law's `tryEval` fold path
  mints `vpiUIntConst` unconditionally.
* **R3 — an enum member's literal changes encoding.** `vv6_edge`, `ev: E_B`:
  golden `vpiConstType:7` (`INT:9`), ours `vpiConstType:9` (`UINT:9`); value
  and size agree. Same cause as R2 — one synthetic UINT for every folded
  value, against pass 49's "the substituted leaf's encoding follows the reduce
  table".
* **R4 — the positional pattern form.** `vv1a_pos`: golden folds
  `'{3, 16'hBEEF}`; the predicate tests `StructuredAssignmentPattern` only, so
  we decline. Widening it needs the positional→member mapping, which the
  pass's W2 walk does not carry.
* **R5 — cross-assign SHARING of the Hex/Bin/Dec reduce products.** The
  implementer's own R5, reproduced: `ve6_adjust_table` / `vv7_gensubst`. Not
  a divergence of `adjustSize` (see `vv4_singleread`), but of WHICH object
  golden re-sizes: one shared product, last writer wins.
* **R6 — the census's own radius.** `shapes55.py` names 23 directories; a
  looser dir-level scan (a parameter of a user type anywhere in the dir plus
  any dotted read on an assign anywhere in the dir) names **65**, including
  `ibex`, `rp32`, `Opentitan`, `ariane`, `black-parrot`, `Earlgrey_0_1` and
  the whole `iface_*` family. The text census is not what closes that gap —
  the byte comparator is: every database in both corpora was compared law-vs-
  pristine, and outside the witness every one is byte-identical.
* **R7 — the cell trace does not name every reaching cont_assign.**
  `R11U55_CELLDBG=1` on `ve1` prints 5 of the arm's 7 continuous assigns; the
  bit-select and part-select Lhs cells never reach the traced statement.

## 5. R0 for the next pass

R2 (the generate-scope share decision) is still the widest remaining road-E
cell with corpus sites. Ahead of it in *correctness* order, though, is the
encoding of the substituted value: **R1/R2/R3 above are one defect — the fold
path mints `vpiUIntConst` for every value it evaluates and leaves an unsized
constant unsized.** A pass that reads the producer's reduce table for the
signed, enum and unbased-unsized leaves closes all three, and it is the same
table pass 49 already decoded for a different site.

## 6. Reproducing

```bash
git worktree add /tmp/wt_v /tmp/…455f226d ; git apply -3 r11u55.verified.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
      -Dslang_DIR=~/.local/lib64/cmake/slang -DUHDM_DIR=~/.local/lib64/cmake/UHDM
cmake --build build -j 2
GRID=tools/probe/r11v55repro/grid bash tools/probe/r11v55repro/run55v.sh build/slang-uhdm fix
python3 tools/probe/r11u55repro/caread55.py <arm>/gold.fix.dump ELAB
```

`run55v.sh` takes the binary and a tag, records `golden_rc` AND `ours_rc` for
every arm, and drives Surelog v1.87 at
`~/git-repos/Surelog/build/bin/surelog` with `uhdm-dump` / `uhdm-cmp` from
`~/git-repos/UHDM/build/bin`.
