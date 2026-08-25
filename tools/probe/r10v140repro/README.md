# r10v140 — the ADVERSARIAL VERIFIER's dir for UVM pass 140 (§ `retNamedTdWinsOverCanon140`)

**MEASUREMENT-ONLY.** Nothing here is an acceptance judge; the official
`~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are.
**LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.**

`VERIFIED.r10uvm140.txt` is the verdict and every re-measured number:
**ACCEPT AS SHIPPED**, no production change by the verifier.

## What is here

| file | what it is |
|---|---|
| `v140_p_kinds.sv` | typedef KINDS (enum / packed struct / packed union / vector) × base / alias-of-typedef / 2-deep chain / second-alias-of-one-base, over the class-property, class-local, method-formal and method-return faces |
| `v140_q_homes.sv` | seven HOMES + two more: `$unit` function, `$unit` class method, package function, in-body package-class method, OUT-OF-BODY package-class method, module function, module-class method, NESTED class, interface method |
| `v140_r_import.sv` | the alias in a DIFFERENT package from its base, reached by wildcard / explicit-single / fully-qualified import; three aliases of one base; a class-scope typedef that SHADOWS a wildcard-imported package typedef of the same name (finding **F1** / residue **R4**) |
| `v140_s_spec.sv` | a parameterised class specialised twice and three times, a `$unit` class, 1/2/3 instances of an alias-returning module, and a type-PARAMETER return |
| `v140_t_order.sv` | DECLARATION ORDER, which is what the pristine bug keyed on: four aliases over one canonical enum with the USED one declared 1st / 2nd / 3rd / as an alias-of-alias; an alias declared AFTER the class that used the base; class-scope aliases of a foreign package's typedef |
| `v140_u_cross.sv` | the law against the other committed typedef laws: a cast target naming the ALIAS and one naming the BASE, a parameterised class specialised on alias / base / struct, a bare-enumerator return, two SIBLING classes of one package. (A package alias of a CLASS-scope enum is rejected by Surelog itself — `CP0317 Undefined type` — so this arm carries no such face.) |
| `v140_w_inherit.sv` | INHERITANCE: a virtual base class, two derived classes, a pure virtual returning the alias, and a derived class that RE-TYPEDEFS the same name |
| `armv140.sh` | builds ONE arm with Surelog and with BOTH frozen binaries in BOTH views, dumps all six, runs the official `uhdm-cmp` on all four golden-vs-ours pairs, and reports whether OUR two databases moved. Every child gets `</dev/null`; every rc is printed (rc=139 is a SEGFAULT that `verify_golden.py` would have filed as `SLANG_REJECT`) |
| `pathcen.py` | **the broad instrument.** A dump census of EVERY `\|vpiActual:` binding in a database, keyed by the PATH of enclosing objects and fields, so class properties, class-scope locals, method formals, typedef listing entries and returns are all cells — the implementer's census keyed only the RETURN. Values carry kind+name only: no file, no line, no span (our objects carry no file, and spans are not Compare-visible). Sorted MULTISET per key, so a DEF/ELAB duplicate cannot be dropped by a last-writer dict |
| `pathscore.py` | scores golden / pristine / patched with `pathcen`: `TOGOLD`, **`MOVED-WRONG`**, `CHANGED-STILL-WRONG`, `CHANGED-NOGOLD`, `UNCHANGED-OK`, `UNCHANGED-WRONG` |
| `ARMS.r10v140.txt` | the scored grid: **90 TOGOLD, 0 MOVED-WRONG**, plus the arena object counts |

## Running it

```bash
PRIS=<pristine binary> PATCHED=<patched binary> bash armv140.sh v140_t_order.sv <outdir>
python3 pathscore.py <outdir>/g.dump <outdir>/o.dump <outdir>/q.dump t_order:def
python3 pathscore.py <outdir>/ge.dump <outdir>/oe.dump <outdir>/qe.dump t_order:elab
```

`objcnt140` (in `tools/probe/r10uvm140repro/`) is the AWAY test: it counts
DISTINCT objects in the Serializer arena, not dump occurrences, and reads
identical pristine vs patched on all 28 arm databases.

## The one-line verdict

The law is a **binding**, not a mint: over 34,218 binding cells of a real
SimpleUVM database and 28 arm databases, three cells and 90 grid cells move,
every one of them onto golden's own name, and **not one cell that was already
right became wrong**.
