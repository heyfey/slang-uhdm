# r10v171 — the adversarial verifier of r10uvm171

**VERDICT: ACCEPT.**  Every headline number in the implementer's report was
reproduced bit-for-bit from binaries this verifier built itself; the law was
attacked over six new arms covering the listing faces, the homes, the return
types and the import kinds, and it produced **0 pristine-right → patched-wrong
cells and 0 AWAY-GOLDEN cells**.  Full transcript with every measurement:
[`VERIFIED.r10uvm171.txt`](VERIFIED.r10uvm171.txt).

The judge is `~/git-repos/UHDM/build/bin/uhdm-cmp` and nothing else
(md5 `2ad8015175758e918de1789b86ef1ea5`, the same file as `~/.local/bin/uhdm-cmp`
that `rowheads.sh` defaults to — checked, because a driver comparing with a
different comparator would be measuring nothing).  LHS is always golden.

## What is here

| file | what it is |
|------|------------|
| `VERIFIED.r10uvm171.txt` | the whole verification: binaries, gates, mover attribution, heads, canaries, boundary, the arm grid, the code review and the ranked residues |
| `vgrid171.sh` | the verifier's grid driver — Surelog golden + BOTH binaries in BOTH views, every command and every rc echoed into `cmds.txt` with its binary PATH, DEF and ELAB listings kept apart, scored by `ct171pred` AND by the official `uhdm-cmp` |
| `vscore171.py` | DIRECTIONAL scorer: joins the three listings of one view as multisets keyed on `(line:col, kind, subroutine)` and reports **BROKE** (pristine right → patched wrong), **OVER** (away from golden), **UNDER** (a miss) and **FIXED** |
| `v171_a_selonly.sv` | a clone body whose return name is touched ONLY in select / receiver position, plus a mixed control |
| `v171_b_faces.sv` | the listing faces — leading block, named `begin`, mid-body begin, three nested begins with locals, read-only, only-local-is-the-return, `automatic`, `static`, `void`, task, a SHADOWING same-spelled local, a two-deep receiver chain — with THREE importers of the one home package |
| `v171_c_homes.sv` | package free fn / class in-body / class out-of-body / module fn (with the part-select family) / interface fn, over 1..3 module instances |
| `v171_d_types.sv` | unpacked-array, queue, dynamic-array, packed-struct, associative-array and class-handle returns in a clone |
| `v171_e_import.sv` | wildcard vs EXPLICIT import, a two-hop import chain, a qualified-call importer, and a module-level wildcard import |

Reproduce an arm:

```bash
g++ -O2 -std=c++17 ../r10uvm171repro/ct171pred.cpp -I ~/.local/include \
    -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o /tmp/v171_ct171pred
bash vgrid171.sh v171_b_faces.sv <pristine.bin> <patched.bin> /tmp/v171_gB
python3 vscore171.py /tmp/v171_gB def
```

## The two findings that changed how the law reads

**The symbol-keyed discriminator is load-bearing, and the arm proves it.**
`v171_b_faces.sv`'s `f_shadow` declares `string f_shadow;` inside a named
`begin` and selects it.  Golden's own dump binds those references to
`string_var (faces_home_171::f_shadow::sb171::f_shadow)` @124:14 — the
**shadowing block local**, not the home function's `Return`.  The patch leaves
them bare, because site 2 reads the symbol off `recv` and sites 1/3/4 off
`nv.symbol`.  An implementation keyed on the name TEXT would have bound three
keys to the wrong object here, and the corpus would never have shown it.

**The order-only boundary movers are not a reproducible set.**  This verifier's
boundary over the whole probe tree reports `LISTED=4784 PROCESSED=4784
MOVED_ARMS=15 RC_DIFFS=0` — 3 of the pass's own arms, 4 of this verifier's, and
8 pre-existing.  The implementer measured 9 pre-existing, and only 4 of them are
the same arms, on **byte-identical binaries**.  Both sets are content-identical
and produce byte-identical `uhdm-cmp` text, and a pristine-vs-**pristine**
boundary over the ten families involved reports `MOVED_ARMS=0`, so nothing is
weakened; but the moving arm is the `weaklyReferenced` tail reordering under an
allocation-pattern change, and a future pass must not treat a named order-only
mover list as reproducible across machines.

## Residues (ranked; every one is pristine == patched, none is a regression)

1. **A clone body with no BARE reference never drains.** `drainFuncRet` skips the
   entry on `pf.refs.empty()` before it can reach the `pf.bindVar` branch, so
   `selRefs171` is dropped when the return name appears only in select or
   receiver position — where golden binds.  16 keys across the arms; corpus-
   invisible at `3d549e59`.  Minimal shape of a fix: `pf.refs.empty() &&
   pf.selRefs171.empty()`.
2. **The leading element of a non-built-in `hier_path` on the return name** —
   a two-deep receiver chain, a struct-member write, a user method on a
   class-handle return.  Golden binds all of them; site 2 covers only the
   one-name built-in receiver.  6 keys.
3. **The explicit-import clone.**  The gate is `pkgImportCloneEmit`; golden binds
   the same cells under `import pkg::fn;` too.  3 keys.  (The two-hop chain and
   the qualified-call importer already bind.)
4. Informational: `f_shadow`'s block-local selects (another law's), and the
   `a_fn().len()` `hier_path` shape that clearing this head unmasks — present in
   the pristine database too, 21 occurrences on each side.

R0 is unchanged and independently confirmed: SeqDriver, both modes, 33 cmp lines
/ 1 head, the MIRROR overload (`LHS: <null>`) on our `constant 32'h04c11db6
id:367` under `param_assign id:366` at `uvm_misc.svh:368`.
