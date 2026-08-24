# r10v122 — ADVERSARIAL VERIFICATION of r10uvm122 § `localBlockStmtSelBinds122`

**VERDICT: ACCEPT.** Production is UNCHANGED from `/tmp/r10uvm122.patch`; this
directory is evidence only. Every headline number reproduced bit-for-bit on
binaries I built myself (`GATES.r10v122.txt`).

**MEASUREMENT-ONLY.** The official `uhdm-cmp` and `scripts/verify_golden.py`
are the authorities. slang was NOT patched; `results/*.csv` READ-ONLY; NO ROW
CONVERTED. **LHS is always golden (Surelog), RHS is always ours.**

## 1. The decode, re-read from Surelog myself

`UhdmWriter::lateBinding` (`~/git-repos/Surelog/src/DesignCompile/UhdmWriter.cpp:3294`)
and its `uhdmbegin` arm (`:3551-3593`) read verbatim: `Variables()` →
`if (ref->Actual_group()) break;` → `Parameters()` → break → `Stmts()`, where an
`assignment`/`assign_stmt` whose `Lhs()->VpiName()` matches and whose Lhs is
neither `ref_obj` nor `ref_var` hands the reference THAT LVALUE. The
`named_begin`/`fork_stmt`/`named_fork` copies are byte-identical. The loop tail
`if (ref->Actual_group()) break;` (`:3736`) makes the first answering block win.
The pass's model is faithful.

Note also `:3552-3557`: question 1 SKIPS a `ref_var`/`ref_obj` declaration, which
is the same exclusion `localVarDecl122` applies.

## 2. My own grid — 8 arms, 2 views, 0 MOVED-WRONG

`v122arms.sh` over `q1shapes q2homes q3scope q4inst q5prec q6clone q7extra
q8scopes2`, scored by `v122cells.py` (payload = the actual's KIND + NAME only —
COMPARE-VISIBLE; spans in a separate column) and `v122score.py` (a MULTISET
join: several census rows share one (ref kind, name, span) key, and a
last-writer dict drops one of them).

| arm | what it varies | result |
|---|---|---|
| q1shapes | 14 select shapes on subroutine-local packed vectors: bit/part/`+:`/`-:`/variable/parameter index, concat lvalue, rvalue-only, non-direct, two-selects, whole-then-select, select-then-whole, declaring-block-also-selects | **+9 TOGOLD**, 0 wrong |
| q2homes | class in-body / out-of-body method local, class property, package variable, task local, initial block-item local, module function local, module var blocking / nonblocking | **+4 TOGOLD (def) +1 (elab)**, 0 wrong |
| q3scope | named begin, two-levels-out, inner-block-hidden, shadowing decl, for/while/case-item bodies, fork arm, declaring-block-first | **+7 TOGOLD**, 0 wrong |
| q4inst | one and three instances of a module using a package function, wildcard import | **+1 TOGOLD**, 0 wrong |
| q5prec | `ref` formal, typedef'd local, class-typed local (`hh.hv[…]` hier_path lvalue), enum constant beside, function-local-parameter range | **+3 TOGOLD**, 0 wrong |
| q6clone | home package + WILDCARD importer + EXPLICIT importer + importing module | **+2 TOGOLD on the home, clone cells UNMOVED** |
| q7extra | compound assignment ON the select, three nested select-bearing blocks, two sibling blocks, multi-declarator decl, queue local beside, do-while, foreach, the select's own index variable, unpacked element | **+12 TOGOLD**, 0 wrong |
| q8scopes2 | interface task, program block, generate block, `var logic`, virtual/static/nested-class methods, `$unit` function | 0 TOGOLD, **1 MOVEDOTHER** (§4 R-V1) |

**38 TOGOLD in the DEF view + 1 in the ELAB view = 39, with 0 MOVED-WRONG, 0 AWAY and 0 ONESIDED_PAT across all 16 arm-views.**

Decisive golden-verified NEGATIVES (golden keeps the DECLARATION, so does the
patch): concat lvalue (`{v[1],w[0]} = 2'b11`), rvalue-only select
(`r = v[3]; v ^= 3;`), select not a DIRECT statement, shadowing declaration,
inner-block select hidden from an outer ref, declaring block reached first.
Decisive POSITIVE discriminators: `q7extra` `Fn_twoSiblings` — each sibling
block's whole ref binds ITS OWN block's select (bit_select in one,
part_select in the other), and `Fn_threeDeep` — the innermost block's select
wins over two enclosing ones. Both golden.

## 3. The clone fence is NECESSARY and correct — proved twice

`q6clone` (my own source): golden's WILDCARD and EXPLICIT import copies of
`mixMu::accMu` bind the HOME package's `bit_var`, while the home package's own
copy binds the `bit_select`. Patched matches on both sides.

Corpus proof: SeqDriver's `adpcm_pkg` clones of `uvm_mem::do_{read,write}::value_s`
bind golden's `string_var uvm_pkg::…` and ours does too, while the `uvm_pkg`
originals move to the `bit_select`. Without the fence these would be 8
MOVED-WRONG per UVM row, exactly the pass's own pre-fence census.

## 4. Residues I measured (ranked)

* **R-V1 (the only over-fire found) — a `program` block.** `q8scopes2`
  `work@ProgBeta.pLoc` @40:7: golden binds **NOTHING** anywhere inside
  `program ProgBeta` (`pClk`, all three `pLoc` refs and `pRes` carry no
  `vpiActual`); pristine binds the `bit_var`, patched binds the `part_select`.
  **Pristine was already wrong**, so this is wrong→differently-wrong, not
  pristine-right→patched-wrong; the row-level verdict on that slot cannot
  change. Zero corpus witnesses (all 11 movers are package/module subroutine
  locals). The real law here is a `program`-scope NO-BIND in the
  `unitSubNoBind9` / `classMethodNoBind` family and needs its own pass; adding
  a `program` fence to THIS pass would move no cell toward golden. **NOT
  patched** — reported.
* **R-V2 — a GENERATE-BLOCK `always_comb` block-item local.** `q8scopes2`
  `work@GenDelta.gblk[i].gLoc` @91:11: golden binds the `bit_select`, we leave
  the reference UNBOUND (all three `gLoc` refs are `<none>` on our side).
  Pristine-identical UNDER-fire — the law's population our reference pool does
  not reach. Cheapest remaining reach for this family.
* **R-V3 — an OUT-OF-BODY class method's PROPERTY.** `q2homes`
  `Widget7::oobM::propVecB` @31:7: golden binds the `bit_select`, we leave it
  bare. Pristine-identical. (The pass's README lists the in-body twin.)
* **R-V4 — `assign_stmt` is not modelled.** `noteLocalStmtSel122` returns on
  anything but `uhdmassignment`, while Surelog's arm also scans
  `uhdmassign_stmt`. Harmless in practice: a procedural continuous assign may
  not target a select, so the shape is unreachable in legal SV.
* Confirmed and reproduced from the pass's own list: R1 package variable read
  from a free package function (`q2homes` `freeFn::pkgLevelVec`, golden
  `bit_select`, we `bit_var`); R2 nonblocking bit-write on a module NET
  (`q2homes` `modVecB`, golden `bit_select`, we `logic_net`); R3 `$unit` and
  interface-task `io_decl`s; R4 the import clone's actual NAMING (arm-f only —
  the CORPUS clones name the home's object correctly).
* **Instrument note (non-blocking):** the pass's `score122.py` `load()` is a
  last-writer dict over a key that legitimately collides (RESUME §9's multiset
  trap). Re-scoring the six `g122_*` arms with a multiset join reproduces the
  DEF totals exactly (236 comparable cells, 189 → 226 agreeing, **37 TOGOLD, 0
  MOVED-WRONG**) and surfaces the claimed ELAB `+1` as an explicit TOGOLD row —
  so the published numbers stand, but the join should be fixed before reuse.

## 5. R0 — the next head, re-read from the judge

Confirmed 28 lines, ONE head, byte-identical to the pass's committed log.
`uvm-1.2 src/base/uvm_factory.svh:919`, the receiver of `.queue`:

```
LHS ref_obj (…::register::m_inst_override_queues)      @919:13-919:35
RHS ref_obj (…::register::m_inst_override_queues[obj]) @919:13-919:40
    both |vpiParent: method_func_call (queue) @919:41-919:46
```

**Precision the pass's write-up owes:** the judge-visible slot is **`VpiName`
alone**. `expr::Compare` never reads a span or a `VpiFullName` (RESUME §9), so
"13–35 vs 13–40" is dump-only colour — the head is a pure NAME law in the
method-call receiver path (uvm89 / buvm14 / buvm23's family).
