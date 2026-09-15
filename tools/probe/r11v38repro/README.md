# r11v38 — the adversarial verification of r11u38, and § dimMemberSelInstValue38v

**VERDICT: ACCEPT WITH FIX.** Both of r11u38's laws are real, decoded right and
land on golden; every headline number reproduces bit-for-bit from binaries
built in this verifier's own worktrees. One defect was found and fixed here:
**§ dimMemberSelBinFold38 took its DIGITS from a binding made in the stale
`currentScope`, so every instance after the first carried the FIRST instance's
member value.** The fix reads the per-instance elaborated dimension instead. It
is byte-inert on both corpora (0 / 1608 uhdm2rtlil databases move) and cures
five wrong cells on a two-instance arm.

Base `6068228a`. Binaries built here, `-j 2`, frozen `chmod 555`:

| binary | md5 |
|---|---|
| pristine (`/tmp/wt_v11u38pris`) | `fad856692f9431ebe8e264a4ed99f3bf` — **the OPS pin and the main tree's** |
| r11u38 as submitted (`/tmp/wt_v11u38`) | `7cc9a38434c99391ba8e604a7a0030e6` — **the implementer's stated md5** |
| r11u38 + this fix (`/tmp/wt_v11u38fix`) | `ff892b60f90271e398bb5b7adadf31c1` |

Every `cmds.txt` of every sweep in this verification was audited by binary PATH:
1742 / 1742 uhdm2rtlil lines name the frozen path and no other.

## 1. What reproduced, bit for bit

| claim | measured here |
|---|---|
| pristine head `struct_param_dim` both modes | 64 cmp lines, 1 head, cmp rc=255 — golden `BIN:…00000100` ct 3 sz 32 `logic_typespec@5:25` against ours `UINT:4` `32'h4` ct 9 `struct_typespec(test_struct_t)`; `evidence/pristine_struct_param_dim.default.cmp` |
| pristine head `ibex_icache` both modes | 64 cmp lines, 1 head, rc=255 — golden `INT:22` ct 7 against ours `UINT:22` ct 9, same `int_typespec@17:13`, on the DEF-listing `param_assign` Rhs at `ibex_icache.sv:17` |
| **the conversion** | `struct_param_dim` CMP_NOTEQUAL → **CMP_EQUAL in BOTH modes**; uhdm2rtlil **776/28 → 777/27** in both modes; ONE row moves, quoted below |
| `ibex_icache`'s head clears | 64 → 60 cmp lines, 1 head, a NEW object: the packed range bound at `ibex_icache.sv:87` (`evidence/law_ibex_icache_newhead.default.cmp`) — the pass's R0, confirmed |
| Surelog suite | 474/9 + 469/8, unchanged, both binaries |
| the implementer's own grid | `g1` 12/0/0, `g2` 11/0/1, `g3` 5/0/0 — re-scored here from freshly compiled databases, identical |
| the implementer's boundary table | `v1_earl52` 5, `a3_earl52` 1, `vfa_v60` 2, `wa` 1, `v187_i_signedonly` 1, `vfe_v60` 1+1 MOVED-WRONG (golden rc 4), `vff_v60` 1+1 MOVED-WRONG (ours rc 4) — **12 TO-GOLDEN, 0 AWAY**, identical |
| byteverify uhdm2rtlil (SELFCHECK on) | **4 / 1608**, exactly the two predicted rows × 2 modes |
| byteverify Surelog (SELFCHECK on) | 4 / 960, all UVM, order-blind one `UINT:<n>`/`vpiDecompile:<n>` pair each, moving BOTH ways |
| canaries / ctcan2 / canaudit | `ok=52 changed=0` and `ok=8 changed=0` against this verifier's own pristine sweep; ctcan2 PASS/PASS; canaudit `audited=29 UNCOVERED=0 FENCE-BREACH=0` |
| canary databases | `Earlgrey_0_1` `8bdf25272e08` / `59d0ee6d10c3`; `SVSwitch` `4842211c4030`; `YosysVerx` `6ccda350c24a`; `InterfaceModPort` `59a365f3ce2c` — **byte-identical across pristine, law and fix** |
| UVM rowheads | `SeqDriver`, `SimpleUVM`, `Scoreboard`, `MiniAmiq`, `BuildUVMPkg`, `Earlgrey_0_1` 0 lines / 0 heads both modes; `Rggen`/default's own head byte-identical to pristine's |

```
< struct_param_dim,default,CMP_NOTEQUAL,decompile:,,
> struct_param_dim,default,CMP_EQUAL,,,differ
< struct_param_dim,testflags,CMP_NOTEQUAL,decompile:,,
> struct_param_dim,testflags,CMP_EQUAL,,,differ
```

`results/*.csv` was READ ONLY here as well; the patch touches none of them, and
the four slang-fenced names are dispatched by no driver in it (checked by the
OPS fence scan over the whole patch: 0 / 0 / 0 / 0).

## 2. THE DEFECT — § dimMemberSelInstValue38v

`arms/v1_memsel.sv` instantiates ONE module TWICE: `u_ovr` with
`#(.P1(32'h9), .PG(12'h0A3))` and `u_def` at the defaults `32'h4` / `12'h0F5`.
Golden folds each instance's own member value. The law, as submitted, wrote the
FIRST instance's value into BOTH — `evidence/celldbg_law_v1_memsel.txt` against
`evidence/celldbg_fix_v1_memsel.txt`:

```
law   R11U38 DIM mem1 @21:15 w=32 bits=…00001001     (the OVERRIDE, in u_def)
fix   R11U38 DIM mem1 @21:15 w=32 bits=…00000100     (u_def's own default)
law   R11U38 DIM memu @23:15 w=4  bits=0011          fix  0101
law   R11U38 DIM mems @24:15 w=8  bits=00001010      fix  00001111
```

Five cells on that one arm read golden `BIN:…0100` against the law's
`BIN:…1001`, and the pristine arm below had the VALUE RIGHT (`UINT:4`) while
getting the encoding, the typespec and the span wrong. Nothing in the corpus
flips — every such cell is not-equal on both sides — but a law that claims a
cell must not write a number from another instance.

**Why.** `memberSelBinFold38` reads `bp38.getValue()` off the symbol reached
through `be0`, and `be0` is `Expression::bind(*sizeSyn, ASTContext(*currentScope,
LookupLocation::max))`. `currentScope` is STALE throughout `emitInstance`
(RESUME §9), and § dimExprBoundFold79's own comment eight lines above the bind
already records it: *"the bind below FAILS on a gen-scope local and on every
instance after the first … so a law keyed on the bound expression would fire on
one instance and not its twins."*

**The fix**, in `src/TypeEmit.cpp` at the call site, minimal and inside the same
claimed cell set: the digit string is rendered from `ua.range.width()` — the
per-instance elaborated dimension this builder already uses for `digits` two
hundred lines above — at the member's own width, and the arm ABSTAINS WHOLE if
that value does not fit the member. The bind keeps only the SHAPE (the member
width and the member's typespec). Cell membership is unchanged; only digits
that were wrong move.

| arm | as submitted | with the fix |
|---|---|---|
| `arms/v1_memsel.sv` | TO-GOLDEN 17, **MOVED-WRONG 8** | TO-GOLDEN **22**, MOVED-WRONG 3 |
| `arms/v2_paenc.sv` | TO-GOLDEN 11, MOVED-WRONG 0 | unchanged |
| `arms/v3_pa2.sv` | TO-GOLDEN 2, MOVED-WRONG 0 | unchanged |
| `arms/v4_memsel2.sv` | TO-GOLDEN 4, MOVED-WRONG 0 | unchanged |
| **AWAY-GOLDEN** | **0** | **0** |

The three MOVED-WRONG cells that survive are shapes where GOLDEN DOES NOT FOLD
AT ALL and pristine already did: a QUALIFIED package struct parameter
(`mem[mp1::PP.b]`, golden keeps a `hier_path` operand) twice, and an interface's
DEFINITION-listing array net. Both are pre-existing; the law inherits them and
makes neither worse.

Cost of the fix, measured: `byteverify` fix-vs-law over uhdm2rtlil is **0 /
1608**; the implementer's three grid arms compile BYTE-IDENTICAL under both
binaries; the trace-free boundary over 7058 committed arms names the SAME 13
arms for both; goldens 23 PASS / 0 FAIL; the Surelog suite stays 474/9 + 469/8;
every canary database md5 above is unchanged.

## 3. THE TRACE-FREE BOUNDARY — and three arms the trace did not name

`vbnd38v.sh` compiles every committed probe arm with BOTH binaries and
BYTE-COMPARES the databases, so it sees an arm the law's own trace does not
claim. **LISTED == PROCESSED == 7058**, 13 arms DIFF (`evidence/boundary_tracefree_*.txt`):
the 7 the implementer named, this pass's own 3 grid arms, and **three more**:

```
r10buvm22repro/g22.sv                      (both compiles rc=4)
r10uvm154repro/l154_noenum.sv              rc 0/0
r10uvm185repro/grid185/g185_e_kinds.sv     rc 0/0
```

Attributed, not waved away: the moving cell on those arms is an ASSOCIATIVE-array
dimension bound our emitter renders as a huge integer — pristine `UINT:23027385`
against the law's `UINT:23039705` — and the **NEUTRAL** binary (`R11U38_OFF=1`,
which computes and writes nothing) produces the law binary's database byte for
byte there (`fcc0cec34d06…` for law, off AND fix; `547d74005f59…` for pristine).
So the value is BUILD-DEPENDENT and pre-existing, not either law. It does mean
the implementer's "the neutral binary IS pristine" control holds on the corpus
(where it was measured, 1608/1608) but NOT on the committed probe arms.

## 4. THE SURELOG BYTE MOVERS — a stronger control

Four of 960 databases move, all UVM, each one `UINT:<n>` + `vpiDecompile:<n>`
order-blind and in BOTH directions (`1169→1044`, `1090→1251`, `1208→0`;
`SimpleUVM` differs by ORDER only, 0 order-blind lines). The set this verifier
drew is not even the set the implementer drew. The control:
**the same frozen pristine binary, three consecutive runs of MiniAmiq's own
command line, produced three different databases** (`evidence/uvm_coin_positive_control.txt`).
That is the documented per-invocation coin, and no cell of either law appears in
any of them.

## 5. Residues this verification adds

* **RV1 — the qualified package struct-param member dim.** `mem[mp1::PP.b]`:
  golden keeps an unfolded `hier_path` operand where we fold a constant, on both
  binaries. Pre-existing; the first shape found where golden declines the fold
  this law otherwise models.
* **RV2 — an associative-array dim bound is a BUILD-DEPENDENT integer.**
  `UINT:23027385` / `UINT:23039705` on `l154_noenum`, `g185_e_kinds`, `g22`:
  stable per binary, different across binaries, unrelated to any law. Any future
  pass's "the neutral binary is pristine" control must be measured on the arms it
  will be used on.
* **RV3 — the type-parameterised base abstains.** `parameter type T = p2_t,
  parameter T PT = …` then `mem[PT.a]` is not claimed (the declared type is not a
  named packed-struct typedef); golden folds it. `arms/v4_memsel2.sv`.
* **RV4 — hygiene.** The new dim arm re-writes `VpiValue`/`VpiSize` on a
  constant the generic arm above it already stamped, so the first string is
  discarded in the serializer's table. Measured cost on the converting row: the
  law's database is 195 bytes SMALLER than pristine's (the per-use struct
  typespec clone it stops minting more than pays for it).

## 6. Reproducing

```bash
tools/probe/r11v38repro/vgrid38v.sh <pristine> <candidate> [outdir]   # the four arms, both producers
PRIS=<pristine> LAW=<candidate> ROOT=tools/probe OUT=<dir> \
  tools/probe/r11v38repro/vbnd38v.sh                                  # 7058 arms, trace-free
```
