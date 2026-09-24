// r10uvm201 grid arm A — the UNTYPED DEFAULT FORMS of a wildcard file-scope
// import, one package, one module.  Measures the materialized copy's folded
// param_assign Rhs CONSTANT typespec per default form.
package p201a;
  parameter A_DEC  = 13;
  parameter A_UHEX = 'hf000000;
  parameter A_SZ   = 8'hab;
  parameter A_STR  = "hello";
  parameter A_EXPR = 1 + 2;
endpackage
import p201a::*;
module m201a;
endmodule
