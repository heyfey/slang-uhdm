# r11v70 — adversarial verification of r11u70 (`castNamedPatternConcat70`)

Base `3e392403`.  Pins per `SUPPORT_MATRIX.md`: slang `7d61e0ad1`, UHDM v1.87,
Surelog v1.87 at `~/git-repos/Surelog/build/bin/surelog`, uhdm2rtlil v0.68.
Every golden in this directory is a real Surelog v1.87 run (`arm3.sh`), never a
carried-forward framing.  Three binaries, all built here, all frozen `chmod 555`
before any sweep:

| binary | md5 | what it is |
|---|---|---|
| pristine | `575be751afd6818113a6788148e78797` | a fresh worktree at `3e392403` — the hash the brief states |
| law | `e4a5be301d98c37d3f5536d8768882e0` | `/tmp/r11u70.patch` as submitted, applied to a fresh `3e392403` |
| verified | `5b29177972f5ead865d5513a6dd722b0` | the law plus the three fences of §3 |

**VERDICT: ACCEPT WITH FIX.**  The conversion is real and every headline number
reproduced bit for bit.  The law also fires on three faces the golden grid never
reached, and on two of them the PRISTINE binary's net list already matched
golden's — pristine-right → patched-wrong.  The verified patch fences all three;
on both corpora it produces databases **byte-identical to the law's** (0 movers
of 1608 uhdm2rtlil databases), so the fences cost no conversion.

---

## 1. Reproduced, bit for bit

* **Pristine build** md5 `575be751afd6818113a6788148e78797` — the brief's hash,
  from my own worktree.  (The implementer's report calls this "byte-identical to
  the main tree's `build/slang-uhdm`"; the main tree at the time of this review
  carries an unrelated in-flight integration and its binary is
  `ed42e95baf0385529f25f139e2eb32d2`.  The hash that matters — a fresh build at
  `3e392403` — is right.)
* **Law build** md5 `e4a5be301d98c37d3f5536d8768882e0`, 0 errors.
* **The head**, `uhdm-cmp` golden vs pristine, `typed_named_pattern`,
  one head per run (`grep -c '^LHS:'` = 1), both modes the SAME TEXT
  (md5 equal across modes):

```
LHS:
decompile:
ref_typespec: (work@typed_named_pattern), id:103
|vpiParent:
\_operation: , id:102, line:22:35, endln:22:132
|vpiFullName:work@typed_named_pattern
|vpiActual:
\_struct_typespec: (q::op32_i_t), id:13, line:9:11, endln:15:4
RHS: <null>
```

* **The whole residue**: order-blind whole-dump distance golden-vs-pristine
  = **677 lines**, exactly as claimed.
* **Golden net ORDER** in the definition listing, read out of golden itself:
  `o_cast, o_plain, imm_11_0, rs1, funct3, rd, opcode` — the order the law's
  parked-and-drained mint reproduces.
* **Goldens** 23 PASS / 0 FAIL with the law binary; `/bin/false` 0 PASS / 23 FAIL.
* **uhdm2rtlil** pristine 787/17/67 each mode, row-joined against
  `results/golden_uhdm2rtlil.csv`: **0 differing rows**.  Law 788/16/67 each
  mode, and the join flags exactly
  ```
  < typed_named_pattern,default,CMP_NOTEQUAL,decompile:,,
  < typed_named_pattern,testflags,CMP_NOTEQUAL,decompile:,,
  > typed_named_pattern,default,CMP_EQUAL,,,differ
  > typed_named_pattern,testflags,CMP_EQUAL,,,differ
  ```
  and nothing else.
* **Surelog suite** pristine 474/9 default + 469/8 testflags — the committed
  baseline, every bucket.  My pristine join flags only `Earlgrey_0_1`'s blank
  DUMP COLUMN (both modes, status `CMP_EQUAL` on both sides — the documented
  uhdm-dump timeout draw) and the workdir path inside `LowMemLib`/`LowMemPkg`'s
  golden-side `SURELOG_FAIL` string.  **`YosysOpenSparc,default` read
  `SURELOG_FAIL` in the implementer's pristine sweep and `SLANG_REJECT` in
  mine, matching the committed baseline** — confirming their reading of it as a
  golden-producer resource draw and not this pass's.
* **byteverify** `SELFCHECK=1`, law vs my own pristine workdirs, uhdm2rtlil:
  PATH_SETS_IDENTICAL (1608), **MOVERS 2 / 1608**, the two
  `typed_named_pattern` databases and nothing else; SELFCHECK 1607/1608.
* **cmds.txt audited by binary PATH**: 1742/1742 in each uhdm2rtlil workdir,
  **0** main-tree or worktree binary paths anywhere.
* **The census, re-run with an independent instrument** (a comment-filtered
  source scan of `*.sv`/`*.v`/`*.svh`/`*.vh`/`*.svi` over both corpora AND the
  UVM tree) finds **exactly the implementer's five** genuine `T'{…}` sites —
  `typed_named_pattern` (the cell), `rp32/hamster/r5p_hamster.sv:309`,
  `CastStructMember`, `DefaultPatternAssign`, `Verilator/t_struct_init.v:45` —
  plus the same `tagged … '{…}` / `return '{…}` false-positive families.  Zero
  in the UVM tree.
* **The producer** reads as stated: `UhdmWriter::lateBinding` mints a
  `logic_net` and pushes it on `inst->Nets()`
  (Surelog `src/DesignCompile/UhdmWriter.cpp:3996-4007`), and
  `instance::Compare` compares `Nets()` as a VECTOR
  (UHDM `generated/src/instance.cpp:336`), so the list and its order are judged.

---

## 2. Where the law breaks — 22 arms, all real Surelog v1.87

`arm3.sh` runs one arm through Surelog and through each binary, dumps all
sides, and prints the order-blind distance plus each side's definition-listing
NET LIST.  Full text in `evidence/GRID.v11v70.txt`, the three failing faces in
`evidence/AWAY.v11v70.txt`.

**Three AWAY cells — pristine-right → patched-wrong on legal SV:**

| arm | the face | golden | pristine | law |
|---|---|---|---|---|
| `v17` | `` `default_nettype none `` | net list `o` ALONE, 2× `[ERR:EL0535] Illegal implicit net`, key refs with no actual | `o` — **matches golden** | `o,a,b` |
| `v20` | a key naming a WILDCARD-IMPORTED package `localparam` | the key operand is that parameter's 32-bit CONSTANT; net list `o` | `o` — **matches golden** | `o,a,b` |
| `v21` | a key naming a WILDCARD-IMPORTED enum constant | key ref bound to `enum_const (a)`; net list `o` | `o` — **matches golden** | `o,a,b` |

Both causes are in the producer and both are readable:

* `UhdmWriter.cpp:3966-4008` mints **only** when the holder's `default_nettype`
  is a real net type, and stamps `getVpiNetType(that type)`.  Arms `v18`/`v19`
  show the second half of the same fact: `wand` → `vpiNetType:2`, `tri` → `4`,
  where the law writes a flat `1`, and `nets::Compare` reads `VpiNetType`
  (`generated/src/nets.cpp:277`).
* `lateBinding` searches the design's enum constants and the imported packages'
  parameters and variables **before** the mint
  (`UhdmWriter.cpp:3860-3960`), while slang's `Scope::find` answers for DIRECT
  members only and says so in its own body — it returns `nullptr` for
  `ExplicitImport` outright (`slang Scope.cpp:546-570`).  The law's `c10` fence
  is `home.find`, so every imported name slips past it.

**One half-fire — the law taking NEITHER road:**

* `v1` (a package declaring `localparam p2_t PK = p2_t'{a: 4'd1, b: 4'd2}` and
  reading `PK.a` in its own scope, which is what turns the flatten on).  The
  report states this face is "fenced by `ps.getParentScope() == &body`", but
  inside the PACKAGE's own `emitParameters` that test is **TRUE**: the road
  cleared `structPat` while the shape arm declined for want of a module to bind
  against, and the parameter landed on a third shape.
  `uhdmtopPackages / q::PK`:
  ```
  GOLDEN    op67[ op33[ R(q::a) K4:DEC=1 R(q::b) K4:DEC=2 ] ]
  PRISTINE  op75[ K4:DEC=1 K4:DEC=2 ]            (FLAT)
  r11u70    op75[ tp[K4:DEC=1] tp[K4:DEC=2] ]    (TAGGED)
  ```
  `v15` shows the same on an INTERFACE holder.  Neither of ours is golden, so
  this is not an away-golden move — but it is an unmeasured shape produced by
  an admission test and a shape arm that answer different questions.

Everything else the law claims held under attack: `v7`/`v10`/`v13`/`v22` (keys
naming ports, a genvar, a declared logic, a module-local localparam) decline as
the `c10` fence promises; `v12` (a generate-block holder) declines on the scope
test; `v5` mints per instance; `v11` keeps two modules' wires separate;
`v16` keeps SOURCE key order (`b,a`) exactly as golden does; `v3` (a
compilation-unit typedef target), `v6` (a parameter port), `v8` (a typedef
alias) and `v9` (a module whose net list was empty before the mint) all move
TOWARD golden.

---

## 3. The verified patch — three fences, each on its arm

All three are in the law's own single admission test / its road, and all three
only ever DECLINE:

1. **`castMintDefaultNetType70v`** (`src/ExprEmit.cpp`) — the law owns the
   plain-`wire` default and nothing else.  `home.getDefaultNetType().netKind
   != NetType::Wire → return false`.  Arms `v17`/`v18`/`v19`.
2. **`castKeyImportedBind70v`** (`src/ExprEmit.cpp`) — a key name that an
   UNQUALIFIED lookup can see binds in golden, so it is not this law's.
   `Lookup::unqualified(home, knm70)` beside the existing `home.find`.
   Arms `v20`/`v21`.
3. **`castAdmitNeedsHome70v`** (`src/ParamEmit.cpp`) — the two halves must
   agree: the road admits only when `castKeyNetHome70` is open, which is
   exactly when the shape arm can fire.  Arms `v1`/`v15`.

**Cost: zero.**  `byteverify` of the verified workdir against the LAW workdir
over the whole uhdm2rtlil corpus reports **MOVERS 0 / 1608** — the two binaries
write the same bytes everywhere a corpus test reaches.  Re-scored on the 22
arms: **AWAY 0, MOVED-WRONG 0**, every TOWARD arm at exactly the law's distance.

---

## 4. Residues the verification opened (ranked)

* **R1 — a NESTED cast inside an admitted pattern mints only the OUTER keys.**
  Arm `v4`, `out_t'{a: inr_t'{x: 4'd1, y: 4'd2}, b: 4'd3}`: golden's net list is
  `o,a,x,y,b` — the inner cast is another `op67/op33` with its own mint — and
  ours is `o,a,b`.  Not a regression (pristine's `o` is wrong too), but the law
  reaches a shape it never measured.  `castPatLiteralVal70` accepts a nested
  `StructuredAssignmentPattern` without asking whether it carries a cast type;
  the one-line fence is to decline when it does.  No corpus cell.
* **R2 — the mint's `vpiNetType` is `default_nettype`'s.**  Arms `v18`/`v19`:
  golden stamps 2 for `wand` and 4 for `tri` where the shape arm writes 1.  The
  verified patch declines those holders rather than modelling the map; modelling
  `getVpiNetType` is the smaller of the two remaining halves.  No corpus cell.
* **R3 — the PACKAGE and INTERFACE holders.**  Arms `v1`/`v15`: golden writes
  the same `op67/op33` there (and `lateBinding` mints for `uhdminterface_inst`
  and `uhdmprogram` as well as `uhdmmodule_inst`), and the verified patch now
  declines both cleanly instead of half-firing.  Opening them means giving
  `castKeyNetHome70` the other two instance kinds and deciding the package's
  own binding rule.  No corpus cell.
* **R4 — a key that binds rather than mints is a PER-KEY fact, not a
  whole-pattern one.**  Arm `v22`: golden binds `a` (dangling, a module-local
  localparam) and mints `b` in the SAME pattern, while both `c10` and this law
  decline the whole pattern when any one key is declared.  No corpus cell.
* The implementer's own R0 (the unpacked cast face's elaborated listing) stands
  unchallenged: arm `v3`'s def cell converts and nothing here moves it.

---

## 5. Files

| file | what it is |
|---|---|
| `arm3.sh` | one arm through Surelog + every binary in `BINS`, dumped, normalised, with each side's net list |
| `arms/v1.sv` … `arms/v22.sv` | the 22 adversarial arms of §2 |
| `evidence/GRID.v11v70.txt` | the three-way grid: distance to golden and the net list, per arm, per binary |
| `evidence/AWAY.v11v70.txt` | the three AWAY cells and the half-fire, with golden's own text |
| `evidence/GATES.v11v70.txt` | every gate, measured here |
| `canaries.sh`, `ctcan2.sh`, `canaudit.sh` | the standing battery (r10uvm221 generation, byte-identical copies) |
