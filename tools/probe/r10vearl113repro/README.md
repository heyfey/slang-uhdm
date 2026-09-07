# r10vearl113 — the ADVERSARIAL VERIFICATION of r10earl113 (§ `genScopeCaPatNoFirstSize113`)

**MEASUREMENT-ONLY probes.**  Nothing here is an acceptance judge; the official
`uhdm-cmp` (`~/git-repos/UHDM/build/bin/uhdm-cmp`) and `scripts/verify_golden.py`
are the authorities for every number below.  slang was **NOT** patched;
`results/*.csv` were **READ ONLY**; **no row was promoted or converted**;
`GOLDEN_DEFER` stayed unset.  The four slang-fenced tests were never dispatched
and are named nowhere in this directory.

**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

**VERDICT: ACCEPT-WITH-FIX.**  Every headline number of the implementer's
report reproduces bit-for-bit from an independent build.  The law then BROKE on
two faces of one hole — the fence tested slang SYMBOL IDENTITY where Surelog's
`bindVariable` does a **NAME** walk — and both were `pristine-right →
patched-wrong` on legal SV.  The fix is 30 lines in the same lambda, it costs
the pass nothing (the Earlgrey databases it produces are **byte-identical** to
the implementer's patched binary), and the whole battery is green on it.
Ship `/tmp/r10earl113.verified.patch`.

| | |
|---|---|
| BASE | `b71d5feb` |
| pristine | md5 `bc09e77cf8fd251285c06f6f0b54a5bc` — built in THIS verifier's own worktree, **byte-identical to the implementer's pristine and to the main tree's `build/slang-uhdm`** |
| implementer's patched | md5 `eb7b95960d659e302e9e8986470f1dcf` — **byte-identical to the implementer's own build**, from `/tmp/r10earl113.patch` applied to a fresh `b71d5feb` |
| VERIFIED (fixed) | md5 `165964dfc796ad3bbcc54d1b5fbead7d` |
| all three | frozen `chmod 555` before any sweep; every `cmds.txt` audited BY BINARY PATH (below) |

---

## 1. THE REPRODUCTION — every headline number, independently

Built both binaries from scratch (`cmake -DCMAKE_BUILD_TYPE=Release`,
`-j 2`), froze them, and ran the whole battery with `SLANG_UHDM` exported
explicitly per binary.

| the implementer claimed | this verifier measured |
|---|---|
| pristine `bc09e77cf8fd251285c06f6f0b54a5bc` | **identical** (and identical to the main tree's binary) |
| patched `eb7b95960d659e302e9e8986470f1dcf` | **identical** |
| patch applies clean on fresh `b71d5feb`, surface = 3 production files + its probe dir | `git apply` rc=0, 0 conflict markers, 54 files, no `results/*.csv`, no RESUME hunk; fence scan **0 hits** on all four fenced names |
| goldens 23/0, `/bin/false` 0/23 | **23 PASS / 0 FAIL** on patched AND pristine; `/bin/false` **0 PASS / 23 FAIL** |
| u2r 679/50/2 both modes, 0 changed rows | **679 / 50 / 2** on both binaries in both modes; `ct8rows` PASS vs the committed baseline AND vs this verifier's own pristine, both modes |
| surelog histogram identical, 0 changed rows, NO conversion | **937 / 19 / 567 / 48 / 10 / 3 / 1 / 2 / 1** on both binaries; `ct8rows` PASS vs the committed baseline AND vs pristine; **no row converted** |
| byteverify u2r MOVERS 0/1358 | **0 / 1358**, SELFCHECK 1357/1358 |
| byteverify surelog MOVERS 3/956 = 2 Earlgrey + the Scoreboard coin | **3 / 956**, the same three paths, SELFCHECK 955/956 |
| **Earlgrey_0_1/testflags 364 → 17 cmp lines, ONE head** | **364 → 17, ONE head** |
| every other rowheads row unchanged | SeqDriver 29/29, SimpleUVM 664681, Scoreboard/default 95, MiniAmiq 29/29, BuildUVMPkg 52/52, Earlgrey/default 31, Rggen/default 0 — **all as claimed** |
| arm grid TOGOLD 13 / AWAY 0 / MOVEDWRONG 0, SAME_AGREE 146, STILLWRONG 5, NOGOLD 15, NOGOLD_UNMOVED 33, ONESIDED 45 | **exactly those nine numbers**, from a re-run of `grid113.sh` on this verifier's own binaries |
| canaries ok=52/8 changed=0, ctcan2 PASS ×2, canaudit audited=29 UNCOVERED=0 FENCE-BREACH=0 | **all reproduced** |

`cmds.txt` audit, by binary PATH, one path per workdir and no other:

```
surelog  patched workdir : 1573 cmds.txt, 1523 × slang: /tmp/vearl113_bin/patched
surelog  pristine workdir: 1573 cmds.txt, 1523 × slang: /tmp/vearl113_bin/pristine
u2r      patched workdir : 1462 cmds.txt, 1458 × slang: /tmp/vearl113_bin/patched
u2r      pristine workdir: 1462 cmds.txt, 1458 × slang: /tmp/vearl113_bin/pristine
surelog  FIXED workdir   : 1573 cmds.txt, 1523 × slang: /tmp/vearl113_bin/fixed
u2r      FIXED workdir   : 1462 cmds.txt, 1458 × slang: /tmp/vearl113_bin/fixed
```

The only other `slang-uhdm` string in any `cmds.txt` is the golden CACHE path
`~/.cache/slang-uhdm-goldens/…`, which is why the audit greps the `slang:` line
and not the substring.

---

## 2. WHERE THE LAW BROKE — `bindVariable` binds BY NAME, not by symbol

The implementer's fence asks slang "is the target's declaring SCOPE this
generate block or one enclosing it?".  Surelog asks a different question.
`UhdmWriter::writeCont_assign` (UhdmWriter.cpp:2121) calls

```cpp
  m_helper.bindVariable(mod, m, lhs->VpiName(), m_compileDesign);
```

— a **NAME** against each enclosing scope's own `Variables()` / `Nets()`
(CompileStmt.cpp:3089-3148), which (a) knows nothing about shadowing and (b)
ends with `return bindVariable(component, scope->VpiParent(), name, …)`, so it
does **not stop at `module_inst`**.  Two consequences, both measured, both
`pristine-right → patched-wrong`:

**(a) A SHADOWED NAME.**  Arm `v1_decl113` cell a3: `sh_v` is declared in the
module body AND again in a generate block, and the generate block's `assign`
targets its own `sh_v`.  Golden's `bindVariable` finds the MODULE-BODY
namesake, fills `tps` from it, runs `expandPatternAssignment` and **SIZES**
operand 0 — golden even re-points the Lhs `ref_obj` at the namesake, which is
why golden's census row for a gen-local assign reads `decl=module_inst`:

```
GOLDEN  PX|52:19-52:58 |sc=gen_scope|gd=1|lhs=…/act=struct_var/decl=gen_scope  |k=hier_path  sz=1
GOLDEN  PX|52:19-52:58 |sc=gen_scope|gd=1|lhs=…/act=struct_var/decl=module_inst|k=hier_path  sz=1
PRISTINE                                                                                     sz=1   <- RIGHT
PATCHED                                                                                      sz=0   <- WRONG
```

**(b) A NAMESAKE ONE HIERARCHY LEVEL UP.**  Arm `v1_decl113` cell a7: the leaf
module's gen-local `a7_nm` is declared nowhere in the leaf, but the PARENT
module declares `a7_nm`.  The walk recurses past `module_inst` into the parent
instance, finds it, and golden sizes.  The official judge sees it directly —
`uhdm-cmp` on the arm, **elaborated view**:

```
PRISTINE head (17 lines) : ref_typespec (…u_a7.gen_a7[0].tl_i[0].v)   <- the R0 residue, size AGREED
PATCHED  head (372 lines): hier_path (tl_i[0].v) 95:26 … |vpiSize:1   <- golden's size, ours now 0
```

Neither face is exotic SV: (a) is any `for`-generate that reuses a module-level
signal name inside the block, (b) is any leaf whose local name also exists in
its parent.  Arm `v6_name113` then found three more of the same hole (a NET
namesake, a PORT namesake and a namesake declared textually AFTER the generate
block), so the unfixed patch scores **AWAY=5** over this verifier's arms.  None
of the five is in the corpus today, which is exactly why the corpus sweeps are
green on both binaries and why the arms had to be built.

---

## 3. THE FIX — the same walk, done Surelog's way

`src/ModuleEmit.cpp`, inside the existing `GenCaLhsGuard113` lambda, after the
identity walk has said "gen-local":

```cpp
  // AND bindVariable BINDS BY NAME, NOT BY SYMBOL (r10vearl113) …
  std::string_view nm113 = lc113.as<NamedValueExpression>().symbol.name;
  if (nm113.empty()) return false;
  for (const Scope* q = &blk; q;) {
      auto& qs = q->asSymbol();
      if (qs.kind != SymbolKind::GenerateBlock &&
          qs.kind != SymbolKind::GenerateBlockArray)
          if (const Symbol* hit113 = q->find(nm113)) {
              const Symbol* v113 = hit113;
              if (v113->kind == SymbolKind::Port)
                  v113 = v113->as<PortSymbol>().internalSymbol;
              if (v113 && (v113->kind == SymbolKind::Variable ||
                           v113->kind == SymbolKind::Net))
                  return false;          // golden binds the namesake and SIZES
          }
      if (qs.kind == SymbolKind::InstanceBody) {
          auto* pi113 = qs.as<InstanceBodySymbol>().parentInstance;
          q = pi113 ? pi113->getParentScope() : nullptr;
      } else {
          q = qs.getParentScope();
      }
  }
  return true;
```

Every clause of it is a `bindVariable` clause and every clause is a MEASURED
cell of arm `v6_name113` (elaborated view, one gen-local keyed pattern per
cell, golden read off the database):

| cell | the namesake is | golden | pristine | FIXED |
|---|---|---|---|---|
| g1 | a module-body **PARAMETER** | `tagged_pattern`, Lhs bound to the CONSTANT — **no size** | sz=1 | **sz=0** |
| g2 | a module-body **NET** (`wire`) | **sz=1** | sz=1 | **sz=1** |
| g3 | a module-body variable declared **AFTER** the generate | **sz=1** | sz=1 | **sz=1** |
| g4 | in an **ENCLOSING GENERATE BLOCK** | **sz=0** | sz=1 | **sz=0** |
| g5 | the module's own **PORT** | **sz=1** | sz=1 | **sz=1** |
| g6 | nothing anywhere (the head shape) | **sz=0** | sz=1 | **sz=0** |

g1 is why the lookup tests the KIND (`bindVariable` reads `Variables()` and
`Nets()` and nothing else — a parameter namesake does not lift the suppress);
g4 is why generate scopes are SKIPPED in the walk (`bindVariable`'s `gen_scope`
falls to `default` and recurses without looking); g5 is why a `Port` hit is
resolved through `internalSymbol`.

---

## 4. THE BATTERY ON THE FIXED BINARY — all green

| gate | result |
|---|---|
| (1) build, md5 | `165964dfc796ad3bbcc54d1b5fbead7d`, frozen `chmod 555` before any sweep |
| (2) goldens | **23 PASS / 0 FAIL**; `SLANG_UHDM=/bin/false` → 0 PASS / 23 FAIL |
| (3) uhdm2rtlil both modes | **679 / 50 / 2**; `ct8rows` **PASS** vs the committed baseline, vs pristine (tf) and vs pristine (default); byteverify **MOVERS 0 / 1358**, SELFCHECK 1357/1358 |
| (4) surelog `--mode both`, 1588 rows | histogram **identical** (937/19/567/48/10/3/1/2/1); `ct8rows` **PASS** vs the committed baseline, vs pristine AND vs the implementer's patched sweep; **NO ROW CONVERTED** |
| (5) byteverify surelog | **MOVERS 2 / 956** — `default/Earlgrey_0_1` and `testflags/Earlgrey_0_1`, the two rows the implementer PREDICTED BY NAME, and **their md5s are byte-identical to the implementer's patched binary's** (`ce0bcd1c1f62`, `fe73264e79bd`).  SELFCHECK 955/956 |
| the coin, proven | `Scoreboard/default` came out `0d80f8f5d07e` (pristine), `6b7c9be975d8` (implementer's patched) and `0d80f8f5d07e` again (FIXED, which contains strictly MORE code than the patched one) — three runs, two values, no correlation with the binary.  RESUME §9's coin, demonstrated rather than asserted |
| rowheads | **Earlgrey_0_1/testflags 17 lines, ONE head**; **every one of the twelve cmp logs BYTE-IDENTICAL to the implementer's patched run** — the fix costs the head fix nothing |
| canaries | surelog **ok=52 changed=0**, u2r **ok=8 changed=0**; `ctcan2` PASS ×2; `canaudit.sh canaries.sh ctcan2.sh` → **audited=29 UNCOVERED=0 FENCE-BREACH=0** |
| protected DBs | all 12 pins SAME vs pristine — `InterfaceModPort 59a365f3ce2c`, `BlackParrotComplex e3e354129d5a`/`73a10e8217e5`, `YosysOldOr d68e0796d62c`, **`SVSwitch 4842211c4030`**, **`YosysVerx 6ccda350c24a`** |
| the implementer's own arms | `grid113.sh` re-run on the FIXED binary: **TOGOLD=13 AWAY=0 MOVEDWRONG=0 SAME_AGREE=146 STILLWRONG=5 NOGOLD=15 NOGOLD_UNMOVED=33 ONESIDED=45** — cell for cell what the unfixed patch scored |
| this verifier's arms | `v1..v6`, both views, on the FIXED binary: **TOGOLD=15 AWAY=0 MOVEDWRONG=0** SAME_AGREE=140 STILLWRONG=1.  The SAME instrument on the implementer's unfixed patch: **AWAY=5** (v1 a3 and a7; v6 g2, g3, g5) with SAME_AGREE 135 — the five cells the fix returns |
| wide boundary | fixed vs pristine over every `.sv`/`.v` under `tools/probe` at any depth, both views: see §5 |

---

## 5. THE BOUNDARY

`widerun113.sh` (the implementer's, re-run with `STAGE`/`COPY` pointed at this
verifier's own scratch) over a COPY of the whole committed `tools/probe` tree
plus this verifier's arms, fenced names filtered out of the list BEFORE a child
runs, `PROCESSED == LISTED` asserted, rc recorded per side.

The differing set is the implementer's own — earl112's four arms and
`r10vearl112repro`'s seven, in both views — plus this pass's own arms as the
POSITIVE CONTROL (proof the gate can see).  Each earlier-pass arm was put back
in front of the OFFICIAL judge on both binaries: `uhdm-cmp` reports the SAME
line/head count on pristine and on the fixed binary for every one of them, so
earl112's law, its user-call-argument fence and earl110's arms are intact by
the only authority that counts.  Full lists in `BOUNDARY_WIDE.*`.

---

## 6. RESIDUES THE VERIFICATION FOUND (none of them blocks this landing)

* **RV1 — `bindVariable` has no `interface_inst` case either.**  Arm
  `v5_iface113`: inside an INTERFACE, golden sizes NOTHING — not the gen-local
  cell, not the interface-body target written from a generate block, and not
  even the plain interface-body `assign`.  All three come out `tagged_pattern`
  (golden never flattens them).  We size at interface-body scope on BOTH
  binaries, so this is pre-existing, not this pass's; it is the same decode one
  `case` wider and it is a candidate law of its own.
* **RV2 — the DEF view.**  For a gen-local target golden's `plain` (non-elab)
  view does not flatten the pattern at all (`tagged_pattern`), while we flatten
  in both views; the suppress therefore lands on an object golden does not have
  there (`NOGOLD`, never scored either way).  Pre-existing on both binaries;
  the implementer's R2/R3 family.
* **RV3 — gen-scope carriers other than `cont_assign`.**  Arm `v3_lhs113`
  (always_comb / initial / delayed assign / net-decl-assign / array-element and
  member-select Lhs in one generate block) sits at 3314 cmp lines on BOTH
  binaries with a DEF-view `named_begin` head — a pre-existing family this pass
  does not touch, now carried by an arm.
* **RV5 — a NON-NamedValue Lhs keeps the stamp by construction.**  A
  `bit_select`, a member select or a hierarchical reference on the Lhs falls
  through both walks, so the pattern keeps the module-scope stamp — pristine
  behaviour, never a regression, but not necessarily golden either: golden's
  `writeCont_assign` only runs `bindVariable` for a `ref_obj` Lhs and takes
  `tps` from `lhs->Typespec()` otherwise.  Arm `v3_lhs113` cells c1/c2 carry
  the shape; both are `NOGOLD`/`ONESIDED` today (golden emits a
  `tagged_pattern` there) and nothing in the corpus moves.
* **RV4 — the delayed continuous assign IS in the law's family.**  `assign #1`
  onto a gen-local target moves with the law (arm `v3` cell c6, TOGOLD in the
  elaborated view), which the implementer's carrier axis did not cover.

---

## 7. FILES

| file | what it is |
|---|---|
| `v1_decl113.sv` | THE DECLARING-SCOPE AXIS pushed past s1: target in the ENCLOSING gen block, module-body target at gen DEPTH 2, **the SHADOWED name (a3)**, the gen-if ELSE branch, an UNNAMED block, a COMMA-LIST assign carrying one gen-local and one module-body target, and **the ancestor-instance namesake (a7)** |
| `v2_pat113.sv` | THE PATTERN-SHAPE AXIS: reversed key order, trailing `default:`, a NESTED pattern as first operand, unsized `'0`, a narrow literal into a wide member, a ternary, a concatenation, and a replication (multi-assignment) pattern — each beside its module-scope twin |
| `v3_lhs113.sv` | THE LHS-KIND AND CARRIER AXES with GEN-LOCAL targets: array element, struct member, net-decl-assign, always_comb, initial, `assign #1`, explicit cast |
| `v4_ctx113.sv` | THE CONTEXT AXIS: the head shape in a SUBMODULE instantiated twice, inside a generate block, and with a per-instance parameter |
| `v5_iface113.sv` | THE SCOPE-KIND AXIS: an INTERFACE's generate block, an interface-body target written from it, and the interface-body twin (RV1) |
| `v6_name113.sv` | THE NAME WALK ITSELF — one cell per `bindVariable` clause (parameter / net / declared-after / enclosing-gen / port / no-namesake) |
| `vgrid113.sh`, `vscore113.py`, `TOPS.txt` | the grid driver and three-way scorer (the implementer's, unchanged, so the two arm sets are scored by ONE instrument) |
| `GRID.r10vearl113.*.txt` | the three-way scores: pristine-vs-implementer's-patch (the **AWAY=1** that convicted it) and pristine-vs-FIXED (**AWAY=0**) |
| `V6.r10vearl113.txt` | the per-cell golden/pristine/fixed transcript of the name walk |
| `BOUNDARY_WIDE.*` | the wide boundary of the FIXED binary against pristine |
| `REPRO.r10vearl113.txt` | the reproduction log: md5s, histograms, ct8rows, byteverify, rowheads, canaries, pins |
