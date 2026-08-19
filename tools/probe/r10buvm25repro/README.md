# r10buvm25 — § foreachPkgClassArrayVar25

**IMPLEMENTER VERDICT: ACCEPT.**  The 56-line BuildUVMPkg head clears in
both modes.  The row remains CMP_NOTEQUAL at a new 72-line head; no corpus row
converts.  Official uhdm-cmp is the judge.  Every measurement uses golden as
LHS and ours as RHS.  Results baselines were read-only.

BASE: 551c0c4899a8335ebcf92d80ddf5e2eff6214fb9.
Production surface: src/StmtEmit.cpp only.  Probe surface: this directory.

## Head decoded from the pristine official cmp

At pp_output uvm_pkg.sv:8507:

    uvm_object_wrapper uvm_deferred_init[$];

and in package function uvm_init at :9847:

    foreach(uvm_deferred_init[idx])

golden lists idx as array_var with a ref_typespec whose Actual_typespec is a
fresh unnamed, location-less array_typespec.  Pristine lists class_var with
class_typespec uvm_object_wrapper: it typed the implicit loop declaration from
the ELEMENT instead of the ARRAY.

The pristine log is 56 lines and contains exactly one LHS head in both modes.
The field is VpiType: BaseClass::Compare checks object type before names or
per-kind fields.  The array_typespec/class_typespec difference below it is the
same defect one level down, not a second head.

## Decoded Surelog law

CompileStmt.cpp:550-565 initially creates every named foreach index as
ref_var + unsupported_typespec, registers it for late typedef binding, and
parents it under VpiLoopVars.  writePackage in UhdmWriter.cpp:1301-1304 calls
lateTypedefBinding only for the elaborated package listing.

UhdmWriter::swapForSpecifiedVar at :2490-2565 decodes the foreach statement's
array reference; at :2546-2548 it passes that ARRAY typespec to
getSimpleVarFromTypespec.  CompileType.cpp:219-233 maps a non-associative
array_typespec (no Index_typespec) to array_var and attaches a newly minted
unnamed array_typespec.  Therefore this head's elaborated package loop
variable is typed from the ARRAY.  The unelaborated twin stays the original
ref_var.

The production gate takes the measured class-handle slice only: bare
package-level queue, dynamic array, or fixed unpacked array; canonical element
kind ClassType; home package elaborated copy.  Package class properties,
formals, subroutine locals, dotted references and associative arrays continue
through the earlier established laws.

## Census, grid, mover prediction

CENSUS.txt calibrates golden-vs-golden at 773/773 and then joins all nine UVM
row-modes as multisets using compare-visible kind/typespec fields.  Whole
family: 9301 agree / 64 differ becomes 9303 / 62.  BuildUVMPkg is 769/4 to
770/3 in each mode; every other row is unchanged.

The 173-object golden grid varies homes, four container kinds, thirteen
element spellings and both views.  Agreement improves 109 -> 125, exactly 16
objects to golden and zero away; all negative controls are byte-identical.
See GRID.txt and g25.sv.

Before the patched corpus sweep completed, the pristine census scanned all
2314 available databases.  Its compare-visible superset had 65 cells; the
exact package-function shape leaves only default/BuildUVMPkg and
testflags/BuildUVMPkg.  Those are exactly the two semantic movers; u2r moves
0/1358.  See PREDICTION.txt.

## Five gates and full boundary

All gates are green: build, 23 golden dumps plus negative control, both
full-corpus sweeps and row gates, byte attribution/canaries/pins, and the
four-way full probe boundary.  No row converts, no baseline changes, no
asymmetric reject, no earlier arm movement.  Scoreboard/default's additional
byte face sorts to zero differing lines.  Exact numbers are in GATES.txt and
BOUNDARY.txt.

## New R0 and residues

R0 is the new BuildUVMPkg head at uvm_pkg.sv:45158 in
uvm_port_component::get_connected_to:

    list[name] = list1[name].get_comp();

assignment::Compare reads Rhs first (equal), then Lhs at generated
assignment.cpp:116-117.  Golden Lhs is a hier_path named
list1[name].get_comp with Path_elems bit_select(list1[name]) then
method_func_call(get_comp).  Ours is only bit_select list1[name], losing the
method-call path suffix.  Both modes: 72 lines, one LHS, byte-identical cmp
logs.

The remaining compare-visible loop-variable census residues are also
pre-existing: BuildUVMPkg's pred is array_var vs class_var, next_pred is
int_var vs class_var, and init_sequence_library's i is int_var vs array_var.
They did not move.  The broader g25 scalar/aggregate and associative cells are
recorded as measured residues, not folded into this narrow pass.

Reproduce with build25.sh, grid25.sh, r10buvm25cen and cencmp25.py.
