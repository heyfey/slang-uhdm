// v201 arm R — an OVERRIDDEN importer parameter beside the import copies, and
// a chain that folds through an overridden value.
package p201vr;
  parameter R_A = 13;
  parameter R_B = R_A;
endpackage
module leaf201vr #(parameter LP = R_A);
  import p201vr::*;
  localparam LQ = LP + 1;
endmodule
import p201vr::*;
module m201vr;
  leaf201vr #(.LP(21)) u();
endmodule
