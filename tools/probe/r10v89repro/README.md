# r10v89 — ADVERSARIAL VERIFICATION of r10earl89 (§ `dimBoundLeafValueSignedTs89`)

**MEASUREMENT-ONLY directory.** The official `~/git-repos/UHDM/build/bin/uhdm-cmp`
remains the sole acceptance judge. **BASE `dcb54b3`, branch `auto5h`.**
`results/*.csv` was **READ ONLY** and is untouched — **NO ROW CONVERTED**.
slang was **NOT** patched. Verifier production surface: `src/TypeEmit.cpp` only
(one behavioural hunk plus one comment correction, both inside
§ `dimBoundLeafValueSignedTs89`).

**VERDICT: ACCEPT WITH FIX.** Every headline number in the implementer's report
reproduced bit for bit on binaries this verifier built itself. One
**pristine-RIGHT → patched-WRONG** cell was found on legal SystemVerilog and is
fixed here; the fixed patch is `/tmp/r10earl89.verified.patch`.

---

## 1. The regression, and why the law had it

`va4_v89.sv` varies the ONE thing the implementer's `g2_chain89.sv` holds
constant: **where the referenced parameter of a bare-reference initializer
LIVES, and how it is SPELLED**, two and three hops deep.

```systemverilog
package pw89;  localparam int          W_INT       = 4;                 endpackage
package px89;  localparam int unsigned X_FROM_QUAL = pw89::W_INT;       endpackage
module  va4_89;
  localparam int unsigned q_2q = px89::X_FROM_QUAL;
  logic [3:0] v_q_2q [q_2q];          // <- golden leaves this bound BARE
endmodule
```

| binary | `v_q_2q` bound leg |
|---|---|
| GOLDEN (Surelog) | `ct9/sz32` **no typespec** |
| pristine `dcb54b3` | `ct9/sz32` **no typespec** — RIGHT |
| r10earl89 as submitted | `ct9/sz32` `TS int_typespec/sgn/bare` — **WRONG** |
| r10earl89 + this fix | `ct9/sz32` **no typespec** — RIGHT |

Scored field-wise on the whole arm, both views:
`TS-WRONG->RIGHT 18, TS-RIGHT->WRONG 3` as submitted → `18 / 0` with the fix.
(3 deduped range ordinals in the definition view and 3 in the elaborated one.)

### the decode error

The pass's comment and README transcribe `CompileHelper::valueRange` as

```c++
switch (rhstps->UhdmType()) {
  case uhdmint_typespec: isSigned = tps->VpiSigned(); break;   // tps == DECLARED?
```

and read it as "the switch names the KIND of `cts`, the SIGN comes from the
declared typespec". **The real code (`CompileHelper.cpp:5379-5398`) casts each
`tps` OUT OF `rhstps`:**

```c++
case uhdmint_typespec: { int_typespec* tps = (int_typespec*)rhstps;
                         isSigned = tps->VpiSigned(); break; }
```

So the sign is the **EFFECTIVE typespec's own sign** — the initializer
constant's typespec when it has one, else the declared one — and never the
declared one once an initializer typespec exists.

That distinction is invisible for a BARE module-scope hop, because there the
initializer's typespec is the one the identifier arm mints from the referenced
parameter's stored VALUE, so "recurse on the Value" and "read the effective
typespec" give the same answer. It is decisive for a **QUALIFIED package hop**,
where the constant carries the package's OWN DECLARED (located) typespec,
minted at the package's declaration and never re-signed by whatever that
parameter's own initializer inherited.

### the fix

One conditional in `paramValueSigned89`:

```c++
    if (inPackage89(rsym) != qual)
        return false;
    if (qual)                                   // r10v89 VERIFIER FIX
        return paramDeclSigned89(rsym.as<ParameterSymbol>());
    return paramValueSigned89(rsym.as<ParameterSymbol>(), depth + 1);
```

`qual` is already forced equal to `inPackage89(rsym)` on the line above, so
`qual == true` is exactly "the hop lands on a package member, spelled
`pkg::X`". Four golden cells separate the two answers and the fix matches all
four (`va4_v89.sv`, GOLDEN = Surelog, both views):

| the hop | referenced parameter | golden |
|---|---|:--:|
| `px89::X_FROM_QUAL` | `int unsigned` ← `pw89::W_INT` | **bare** |
| `px89::X_LOCAL`     | `int unsigned` ← `X_INT` (same pkg, bare) | **bare** |
| `px89::X_INT`       | `int` | **TS** |
| `px89::X_I_FROM_QU` | `int` ← `pw89::W_IU` | **TS** |

i.e. the located typespec's own DECLARED sign decides, in BOTH directions,
whatever the referenced parameter's initializer says. The recursive answer got
row 1 wrong and would get any deeper `int unsigned`-through-a-package chain
wrong the same way.

The production comment's transcription of `valueRange` is corrected in the same
hunk so the next pass does not inherit the error.

---

## 2. What was reproduced, bit for bit

Both binaries rebuilt from scratch in fresh worktrees at `dcb54b3`
(`/tmp/wt_v89pris`, `/tmp/wt_v89`), `-j 2`, frozen `chmod 555` before any sweep:

```
4e11f0b821c3f8f59fe6da4fd43a2b65  pristine   (implementer's number, exactly)
1729de0e79366912a0916945cb8a2e10  patched    (implementer's number, exactly)
f7d164831c9c3ea7c93c1ca3f93a960f  verifier-fixed
```

| claim | verifier measurement |
|---|---|
| goldens 23/0 both binaries, 0/23 on `/bin/false` | reproduced (and 23/0 on the fixed binary) |
| every `cmds.txt` audited by BINARY PATH | surelog 1573 / u2r 1462 per side, **MAIN-TREE=0** |
| u2r 679/50/2, 0 differing rows both modes | reproduced vs the committed baseline AND vs own pristine |
| surelog 0 differing rows / 1588, histograms identical | reproduced; **no row converted** |
| byte movers 0/1358 and 2/956 | reproduced, **same two hashes**: default `ded7aff7a3d0`←`08141341859e`, testflags `8cfc4af7915b`←`ef74c30dc999` |
| `R10E89_OFF=1` reproduces both pristine Earlgrey DBs | reproduced, `08141341859e…` / `ef74c30dc999…` |
| Earlgrey 17→15 cmp lines, 1 head, both modes | reproduced; after-logs byte-identical to the committed `HEAD_AFTER_*` **including object ids** |
| every other named row's head byte-identical | reproduced (12 measured, 2 SKIP-NOFILE) |
| census FAM-TS-MISSING 6→0, FAM-TS-EXTRA 0→0 | reproduced: BOTH-SAME 292269→292275, every other bucket unchanged |
| canaries 52+8 `changed=0`, ctcan2 PASS/PASS, canaudit 29/0/0 | reproduced |
| 5 protected DBs identical, `SVSwitch 4842211c4030`, `YosysVerx 6ccda350c24a` | reproduced |
| wide boundary `PROCESSED==LISTED`, identical=7706, rc 139→28 A/B-symmetric | reproduced (4040 files incl. this dir's arms; identical=7706, DIFFERING=24 = their 18 + this dir's 6) |
| `g1_dims74` +87, `va2_v74` +33, `va3_v74` +18/26, `va1_v74` +6, all R→W 0 | reproduced exactly |
| `r10buvm22repro/g22.sv` is earl84's R5, not this law | reproduced: `R10E89_OFF=1` gives the PATCHED hash, the delta is `UINT:22486617→22490713` on an associative-array key bound, `TS=none` on both sides, golden has no such leg |

Independent corroboration of the prediction: `R10E89_CELLDBG=1` on Earlgrey
prints 63 trace lines, of which **exactly one** changes answer — the RED arm's
`region_end:54:36 par=TotalRegions tsOld=0 tsNew=1` — and **zero** GEN-arm
lines change. Corpus-wide that is closed by the byte-mover gate: only two
databases move at all.

---

## 3. The verifier's own arms

Four arms written without reading the implementer's grids first, each built
with Surelog (GOLDEN), the pristine binary, the candidate binary and the
NEUTRAL one (`R10E89_OFF=1`), in BOTH views, every child `</dev/null` and every
rc recorded. Scored with the pass's own multiset field scorer.

| arm | what it varies | TS W→R | TS R→W | AWAY | other field |
|---|---|---:|---:|---:|---:|
| `va1_v89.sv` | DIMENSION FACES: `[P]`, `[P-1:0]`, `[0:P-1]`, `[P:0]`, `[P:1]`, `[P+Q]`, `[P*2]`, `[(P)]`, `[int'(P)]`, `[$clog2(P)+3]`, literals, 2-D/3-D mixes, packed dims, `[$:P]`, `[$]`, `[]`, `[int]`, `[logic[P-1:0]]`, a typedef's dim, a net's dim | 24 | **0** | 0 | 0 |
| `va2_v89.sv` | LEAF KINDS: enum-typed (`int` / `int unsigned` / `logic signed [7:0]` base) in BOTH arms, packed struct/union signed, `reg signed [7:0]`, `logic signed [W-1:0]`, `time`, a 20-hop `cts` chain, package bare/qualified/`byte`, three OVERRIDE homes, a genvar read directly | 39 | **0** | 0 | 0 |
| `va3_v89.sv` | HOMES: module body, gen-for, gen-if, NESTED generate, an interface declared and instantiated twice, a PORT's unpacked dim (`input`/`output`/`inout`, sized by a header localparam and by the overridden parameter), a 3-deep instance chain with two sibling parents and three differently-parameterised leaves | 42 | **0** | 0 | 0 |
| `va4_v89.sv` | the `cts` recursion's QUALIFICATION COUPLING: package↔module, module→package→package, same-package bare, an interface's own body, `int`/`int unsigned`/untyped sources and sinks in every combination | 18 | **0** (3 before the fix) | 0 | 0 |

Both views score identically on every arm. `R10E89_OFF=1` reproduces the
PRISTINE database byte for byte on all four arms in both views.

### what the arms convict, beyond the pass's own grids

Cells where the **pristine** emitter was WRONG and this law fixes them, none of
which appear in `g1`–`g4`:

* **enum-typed sizing parameters in the GENERIC arm.** `localparam en_i_t e_ref
  = e_lit;` with `typedef enum int {…} en_i_t` — `getType().isSigned()` says
  SIGNED, so pristine stamped; golden leaves it bare and the new `isEnum()`
  exclusion is right. Same for an `enum logic signed [7:0]` base (`v_e_lsr`).
* **packed struct / packed union signed sizing parameters** (`v_st_s`,
  `v_st_sr`, `v_un_s`): pristine stamped on `isSigned()`, golden bare.
* **a localparam sized from an OVERRIDDEN parameter one hop below it**
  (`s_h_ovi = OVI + 0` in all three of `u_def` / `u_lit` / `u_ref`): golden
  stamps, pristine did not — the override refusal is about the parameter
  ITSELF, not about where its value came from.
* **ports**: `pl_s` / `po_s` / `pb_s` sized by a header `localparam int PD =
  DEPTH + 1` all move to golden; their `int unsigned` twins do not.

### two faces that are structurally unreachable, and say so

* **A 1-bit signed scalar can never be a positive dimension bound** (`bit
  signed X = 1` is −1), so slang rejects `[X]` outright: the `ScalarType` leg
  of `paramDeclSigned89` is reachable only through a 2-bit-or-wider packed
  array, which `g1` already covers.
* **A hierarchical `u_if.PARAM` is not a constant expression** in SV, so an
  interface parameter has no dimension-bound face outside the interface's own
  body; `va4`'s `iw89` measures it there instead.

---

## 4. Residues this verification adds, ranked

* **V1 — the `cts` walk stops at 16 hops.** `paramValueSigned89`'s `depth > 16`
  guard truncates a long bare-reference chain: `va2`'s `v_c17` and `v_c20`
  (17- and 20-hop `int unsigned` chains rooted at an `int`) have golden `TS`
  and stay bare. **Pristine was equally wrong**, so this is an incompleteness,
  not a regression; the corpus has no chain that deep (the mover gate moves
  exactly two databases). Raising the bound is safe — slang rejects circular
  parameter dependencies — but it would extend the shipped law, so it is left
  named rather than taken.
* **V2 — a DECLARED-signed sink short-circuits before the initializer's own
  typespec.** `paramDeclSigned89(p)` returns true immediately for `localparam
  int X = pkg::UNSIGNED_THING;`, but the effective typespec is the package's
  LOCATED unsigned one and golden leaves the bound BARE. Measured on `va4`:
  `v_q_i_qu` (`int` ← `pw89::W_IU`) and `v_q_i3q` (`int` ← `px89::X_LOCAL`) —
  golden bare, **both binaries stamp**. Pre-existing on both sides of this
  pass, corpus count 0. The complete rule is "the effective typespec's own
  sign, three kinds only", with the initializer's typespec winning whenever it
  exists; this pass implements the module-scope half of it.
* **V3 — the interface DEFINITION listing gains a typespec on a leg golden
  emits as a `ref_obj`.** `va3`'s `if_s`/`if_ns` and `va4`'s `iw_s`/`iw_fq` at
  the design-level `interface_inst`: golden's bound is `ref_obj:I_S`, ours has
  been a folded constant since long before this pass, and the constant now
  carries a typespec too. The cell disagreed on leg KIND before and after, so
  no cell moved from right to wrong — but it is the same shape the pass ranks
  R2, one notch deeper. Corpus-invisible: `FAM-TS-EXTRA` stays 0 and only two
  databases move.
* **V4 — a latent (pre-existing) cast.** Both the generic arm's `ownFull26` and
  the new RED-arm hunk cast `parent` to `array_var`/`array_net` on a bare
  `UhdmType()` test with no third branch. Today `buildUnpackedRanges` has
  exactly two call sites and both pass one of those two, so the new code adds
  no risk the old code did not already carry — but a third caller would make
  both sites undefined behaviour, not just the new one.

The pass's own R0 (`rv_timer.sv:82:58-82:66`, the width operand of the
elaborated port high_conn indexed part-select in
`top_earlgrey.u_rv_timer.gen_harts[0].u_intr_hw`) is confirmed: the after-head
log is byte-identical to the committed `HEAD_AFTER_*` including object ids, and
identical between the two modes, so there is ONE R0.

---

## 5. Reproducing

```bash
g++ -O2 -std=c++17 dimts89v.cpp -I ~/.local/include -L ~/.local/lib64 \
    -L ~/.local/lib -luhdm -lcapnp -lkj -o dimts89v
DIMTS89=./dimts89v PRIS=<pristine> PATCHED=<candidate> bash arm89.sh va4_v89.sv <dir>
python3 tsscore89.py <dir>/g.rg <dir>/o.rg <dir>/q.rg     # the TS field alone
python3 grid89.py    <dir> def|elab                       # the readable grid
```

`arm89.sh`, `score89.py`, `tsscore89.py`, `grid89.py` and `dimts89v.cpp` are the
pass's own instruments, copied unchanged so the two sides are scored by one
ruler.
