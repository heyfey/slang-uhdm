// r10uvm199 grid arm A — THE UNTYPED HALF OF THE DECLARED-TYPE GRID.  One
// package wildcard-imported at FILE scope, so every parameter is materialized
// into `aTop` twice (§ modUnitImportParamsTwice196).  Each row asks whether
// golden's materialized copy carries a `vpiTypespec` at all, keyed by the
// literal form the untyped declaration was written with.
//
// (The typed half lives in `g199_g_typed.sv`: one package carrying ALL
// thirteen kinds produces a Surelog database this UHDM build SEGFAULTS on
// restore — measured, reproducible on two independent Surelog runs, and the
// reason the grid is two arms rather than one.)
package aPkg;
  parameter A_UHEX = 'hf000000;         // UNTYPED, UNSIZED-BASED hex
  parameter A_UBIN = 'b000000101010101; // UNTYPED, UNSIZED-BASED binary
  parameter A_UOCT = 'o777;             // UNTYPED, UNSIZED-BASED octal
  parameter A_USZ  = 8'hab;             // UNTYPED, SIZED-BASED
  parameter A_UDEC = 13;                // UNTYPED, PLAIN DECIMAL
  parameter A_UDB  = 'd13;              // UNTYPED, DECIMAL-BASED
  parameter A_UNB  = '0;                // UNTYPED, UNBASED-UNSIZED
  parameter A_USTR = "untyped";         // UNTYPED, STRING LITERAL
endpackage
import aPkg::*;
module aTop;
  initial $display(A_UDEC);
endmodule
