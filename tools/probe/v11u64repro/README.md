# v11u64 — ADVERSARIAL VERIFICATION of r11u64 (§ `patFlatUnsizedMemberNoInstWidth64`)

**VERDICT: ACCEPT.** Every headline number reproduced from my own worktrees and
my own frozen binaries; the law survived five new golden grids built to break
it; **0 MOVED-WRONG, 0 AWAY-GOLDEN** on 38 verifier grid keys plus a 959-arm
wide boundary over the committed probe corpus.

Base `ecb98650`. Worktrees `/tmp/wt_v11u64` (patched) and `/tmp/wt_v11u64pris`
(pristine); binaries frozen 555 at `/tmp/v11u64_bin/{pris,law}`.
`results/*.csv` untouched by this verification.

## 1. REPRODUCED, BIT-FOR-BIT

| claim | my measurement |
|---|---|
| pristine md5 = the OPS pin | `44a1172e38bf2ac198365a9b15aea810` |
| law md5 | `8090e35ab1057cc7d4b3e0118a39ce47` — the patch rebuilds byte-for-byte |
| head at the base | `struct_member_cfg_width` **36 cmp lines / 1 head, BOTH modes**; golden `vpiSize:1` vs ours `vpiSize:64` at `dut.sv:31:52`, and a SECOND wrong operand at `31:61` (ours 3, golden 1) |
| head after the law | **0 lines, 0 heads, rc=0, BOTH modes** |
| u2r | pristine `786/18/67` ×2 = the committed baseline exactly (0 differing rows of 1742); law `787/17/67` ×2 with **exactly 2 differing rows**, the conversion |
| surelog | `474/9` + `469/8` on BOTH binaries, statuses identical to the baseline |
| u2r byte movers | **2 / 1608**, the witness both modes; attribution order-blind = exactly `vpiSize:3 -> 1` and `vpiSize:64 -> 1` per database |
| surelog byte movers | **4 / 960** — MiniAmiq ×2, SeqDriver ×2; all four the 4-line `UINT`/`vpiDecompile` LINE-NUMBER class, moving in BOTH directions |
| goldens | 23/0 on both binaries; `SLANG_UHDM=/bin/false` 0/23 |
| cmds.txt audit | u2r 1742/1742, surelog 1531/1581 + 50 with no `slang:` line, **0 other binaries**, in both sweeps |
| canaries / ctcan2 / canaudit | `ok=51 changed=1` (see §4) + `ok=8 changed=0`; ctcan2 PASS ×2; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| protected DBs | every one byte-identical pristine→law, every hard pin at its OPS value |

**The coin, convicted with a positive control the pass did not run.** The
PRISTINE binary alone, three runs of MiniAmiq/default through the harness, drew
`7638da956967`, `27419f6011b4`, `f4e1329ae655` — and `27419f6011b4` is exactly
the hash the LAW binary drew in the sweep. The mover class is the producer's own
nondeterminism.

## 2. THE MODEL, RE-DERIVED FROM THE PINNED SOURCES

`UhdmWriter::writeCont_assign` (Surelog v1.87 `UhdmWriter.cpp:2179-2211`) calls
`ExprEval::flattenPatternAssignments` and then
`CompileHelper::expandPatternAssignment`. The flatten
(`UHDM/templates/ExprEval.cpp:896-918`) re-types a `constant && VpiSize()==-1`
member value with `ExprEval::size(fieldTypes[index], iv, /*inst=*/nullptr, exp,
true, true)`; `ExprEval::size`'s range loop (`ExprEval.cpp:1562-1593`) multiplies
by `getValue(reduceExpr(bound, …, inst, …))` and `ExprEval::getValue`
(`ExprEval.cpp:585`) answers **0 for anything that is not a constant**, so an
instance-dependent bound leaves `(0-0+1)` = ONE BIT. The stamp is written
unconditionally (`invalidValue` is not consulted). The expand sizes with
`Bits(member, …, Reduce::Yes, instance, …)` (`CompileHelper.cpp:5289`) and is
instance-aware. Golden's own witness carries both: `pa` at 64, the two `'0` at 1.

## 3. THE FIVE VERIFIER GRIDS (faces g1/g2/g3 did not hold)

Every grid: Surelog v1.87 `-parse -nobuiltin -nocache -sv -mt 0 -mp 0`, rc=0 and
0 `[ERR`; both binaries rc=0 in both modes; **calibration golden-vs-golden 0 DIFF
first**; scored with `vlist64.py`, an instrument independent of the pass's own.

* **vg1 (14 keys)** — package PARAMETER bound; `2*V-1`; reversed `[0:V-1]`; bare
  `[V:0]`; enum and `bit` members; nested-struct sum; two symbolic dimensions;
  union member; positional pattern; `$clog2` bound; a package `hier_path` bound;
  a FIELD-SELECT Lhs; a TERNARY carrier (both arms); an unpacked decl
  initializer; `'1` + `default:'1`; a `real` beside a symbolic member.
  **TO-GOLDEN 8, MOVED-WRONG 0** (both mode columns).
* **vg2 (13 keys)** — struct typedefs declared IN A PACKAGE (localparam,
  parameter and constant-function bounds); a typedef'd member type and a packed
  array of it; a GENVAR-derived bound; a `default:` fill with NO unvaluable
  operand; `'x`/`'z`; a PACKED decl initializer; an unpacked-array-of-struct Lhs;
  an INTERFACE; out-of-declaration-order setters; a constant-function bound.
  **TO-GOLDEN 1 + 1 partial, MOVED-WRONG 0.**
* **vg3 (9 keys)** — the ARITHMETIC faces, each summed beside a symbolic bound so
  a wrong transcription shows as a wrong NUMBER: byte/shortint/int/longint/bit
  (golden **122**, law **122**, pristine 124), a >64-bit sum (**101** exact), a
  packed array of a nested struct (**18** exact), a `string` member, an enum
  base, an 8192-bit member (the guard declines rather than inventing a width).
  **TO-GOLDEN 3 + 1 partial, MOVED-WRONG 0.**
* **vg4 (2 keys)** — the sharpest MOVED-WRONG face: a `cont_assign` onto a
  PACKAGE-declared struct type whose bounds Surelog folded. **Golden reads the
  REAL widths 5 and 6 there, and the law DECLINES and keeps 5 and 6.** The F2
  fence is load-bearing and measured.
* **vg5 (2 keys)** — the explicit CAST: pristine and law byte-identical, both
  carrying the pre-existing residue. Pass 55's cast fence composes.

## 4. THE WIDE BOUNDARY, AND THE ONE COMMITTED ARM THAT MOVES

`boundary.sh`: all **959** committed probe arms holding an assignment pattern,
`PROCESSED=959 = LISTED=959`, `RC_DIFF=0`, **MOVERS=1**.

`tools/probe/r10vearl99repro/v99_width.sv` moves — and it moves **ONTO GOLDEN**:
scored against a fresh Surelog v1.87 golden it goes **4 diff lines -> 0** in both
modes. The cell is `sub99 #(W)`'s `'{pw:'1, q4:'0}`, where golden writes
`UINT:1` at `vpiSize 32` and at `vpiSize 8` — the VALUE from the no-instance
mask (1) and the SIZE from the instance-aware walk. Pristine wrote
`UINT:4294967295` / `UINT:255`. The pass's report does not mention this arm; it
is a second, unclaimed conversion of an earlier verifier's own adversarial file.

**The one canary that reads CHANGED is `Earlgrey_0_1/testflags`, and it changed
in BOTH of my sweeps identically**: status stays `CMP_EQUAL`, only the dump
COLUMN reads blank — the OPS-documented `uhdm-dump` timeout draw (my machine ran
two sweeps and five grids at once). The DATABASE is the pin and it is at its OPS
value in both binaries: default `8bdf25272e08`, testflags `59d0ee6d10c3`.

## 5. RESIDUES THIS VERIFICATION ADDS

* **Our emitter FOLDS member range bounds that golden keeps symbolic, on three
  shapes reached by this law** — a UNION member (vg1 A7), a directly typedef'd
  member type (vg2 B4 `m1`), and a union inside a nested struct (vg3 vc4).
  There the law cannot fire (F1/F2 see constants) and the cell stays wrong:
  golden 1 / ours 3 for the union; vg3's vc4 moves 10 -> 8 against golden's 6,
  strictly toward golden but not onto it. This is R4's mirror image and the same
  typespec-emission question.
* **Declined faces where golden claims width 1:** a `$clog2(V)` bound (vg1 A13,
  golden 1, ours 4) and a constant-FUNCTION bound (vg2 B12, golden 1, ours 5).
  Fence F3 declines because our bound tree holds a call node; honest, and two
  conversions left on the table.
* **Two transcription divergences from `ExprEval::size`, both unreachable today**
  — an `int_typespec` with a non-null but EMPTY `Ranges()` reads 32 here and 1
  there; and `boundNoInst64` parses a constant by its VALUE PREFIX where
  `getValue` switches on `VpiConstType`, so a prefix/const-type mismatch would
  disagree. Neither can fire without a lost bound elsewhere in the same member.
