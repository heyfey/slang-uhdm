// r10uvm210 grid arm E — THE $unit-SCOPE WILDCARD IMPORT.  Measured
// distinguisher: with the import at compilation-unit scope the def-view
// `ref_obj`'s vpiActual is the referenced PARAMETER, and without it (arms B/C/D)
// it is that parameter's own def-view param_assign Rhs OBJECT.  Same package
// body as arm D so the two are directly comparable.
package p210e;
  parameter E_BASE   = 11;
  parameter E_EXPR   = E_BASE + 1;
  parameter E_REF    = E_EXPR;
  parameter E_REFLIT = E_BASE;
endpackage
import p210e::*;
module m210e;
endmodule
