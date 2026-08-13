// r10earl43 VERIFIER hunt H1 — EMISSION-ORDER dependence.
//
// § defConnPkgParamFold43 reads `pkgParamConst`, which is POPULATED while the
// PACKAGE's def view is emitted.  If a module's def listing is emitted BEFORE
// the package that owns the parameter, the map is empty at the moment the
// connection loop runs and the arm SILENTLY DOES NOT FIRE.  That is an
// under-fire that no probe in the pass exercises, because a1_earl43.sv and
// v43_overfire.sv both declare the package FIRST.
//
// Here the package is declared LAST in the file.
module leafh1 (input logic [31:0] p_i, output logic [31:0] z_o);
  assign z_o = p_i;
endmodule

module toph1 (output logic [31:0] o0);
  import ph1::*;
  leafh1 u_h1 (.p_i (H1_PLAIN), .z_o (o0));
endmodule

package ph1;
  localparam logic [31:0] H1_PLAIN = 32'h 00008000;
endpackage
