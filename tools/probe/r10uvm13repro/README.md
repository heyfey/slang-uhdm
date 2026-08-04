# r10uvm13repro — UVM pass 13 purpose-built pairs

Run one with `tools/probe/r10uvm13run.sh <dir>` (needs `SLANG_UHDM` exported).
It writes `gd/ge` (golden def/elab) and `sd/se` (ours) plus `.txt` dumps into
the directory and prints both diff sizes.  `tools/probe/r10uvm13proj.py <dump>
[line:col ...]` projects a dump onto the reference sites so the binding shape
is readable without reading raw dump lines.

Pass 12 delivered `r10uvm12repro/t13` (the R2 splitting matrix); t14-t17 are
this pass.

| dir | what it pins | status |
|---|---|---|
| t13 | R2 matrix: bare-vs-qualified enum read x home pkg / import clone / class method / oob | § enumNoBind13 + § pkgClassEnumFold13 land the binding + class-qualified halves; the RETURN-position fold and the oob class-enum `logic_net` mockup remain |
| t14 | every position of an enum read inside ONE in-class method: assign, if-condition, case ITEM, user-call arg, system-call arg, own-class enum, cast operand, operation operand | byte-identical, both views (§ enumNoBind13 (a)) |
| t15 | a WRITTEN `p1::PE*` read from a class-in-package method (assign / if-condition / $display arg), next to the oob and free-function twins that already folded | byte-identical on the fold; residue is a `vpiParent` on the `$display` argument constant, which uhdm-cmp does not compare |
| t16 | enum DEFAULT values on formals: package function, in-class method (pkg enum and own-class enum), out-of-body method | NOT implemented — golden emits NO `vpiExpr` at all on these io_decls in either view, while we emit the default; the UVM residue's `Io_decls \| <null> vs enum_const` (264) is the shape where golden DOES emit one, so t16 does not yet reproduce it |
| t17 | the `UVM_*_IMP` macro body: a call on a handle whose type is an unspecialized type PARAMETER (defaults to `int`), so slang rejects the member and drops the whole statement (`statement kind: Invalid`) | NOT implemented — golden shape fully decoded, see below |

## t17: the dropped `Invalid` statement (decoded, unimplemented)

`class impc #(type T=int, type IMP=int); local IMP m_imp; ... m_imp.put(arg);`
— slang binds `m_imp` as `int`, finds no member `put`, and returns a bad
statement, so `emitStmt`'s `default:` arm drops it.  133 sites on SeqDriver, 82
of them in `tlm1/uvm_imps.svh`, the rest in `uvm_sqr_connections.svh`,
`uvm_tlm2_sockets.svh`, `uvm_port_base.svh`, `uvm_pair.svh`, `uvm_misc.svh`.

Golden emits the SAME two shapes the valid dotted-call paths in `emitExpr`
already produce, so the missing piece is a syntax-driven re-entry, not a new
model:

* STATEMENT position (`m_imp.put(arg);`) — a bare `method_func_call` named
  after the METHOD, spanned at the method IDENTIFIER (not the whole call),
  `vpiPrefix` = a ref_obj named after the base (fullname `<prefix>::m_imp`,
  UNBOUND), arguments as ordinary refs which DO bind their `io_decl`.
* EXPRESSION position (`return m_imp.try_put(arg);`) — a `hier_path` named
  `m_imp.try_put`, spanning the WHOLE call, over two path elements: a
  name-only `ref_obj m_imp` (no fullname) and a `method_func_call try_put`
  carrying the arguments.  Here the argument ref is UNBOUND and its fullname
  is `<prefix>::<hier-path-name>::<arg>`
  (`p1::impc::try_put::m_imp.try_put::arg`).

`uvm_pair.svh:66/71` (`first = new;` on a type-parameter-typed property) is a
THIRD shape in the same bucket and is not covered by the two above.
