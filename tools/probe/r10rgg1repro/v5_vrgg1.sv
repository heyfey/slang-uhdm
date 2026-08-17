// v5 — L2 boundary: the OVERRIDE half, package scope, and the `!overridden`
// and `!inPackage` gates the new walk sits behind.
package p_v5;
  typedef enum logic [1:0] { E_A = 2'b00, E_B = 2'b10 } e_t;
  // E1 package-scope localparam with a ternary over enum members (inPackage)
  parameter bit PB = 1'b1;
  parameter e_t PKP = (PB) ? E_B : E_A;
endpackage

module dut_v5 #(
  parameter p_v5::e_t OV  = (1'b0) ? p_v5::E_B : p_v5::E_A,  // E2 default, overridden below
  parameter p_v5::e_t NOV = (1'b1) ? p_v5::E_B : p_v5::E_A   // E3 default, NOT overridden
)();
  import p_v5::*;
  localparam e_t L1 = OV;      // E4 read of an overridden ternary param
  localparam e_t L2 = NOV;     // E5 read of a non-overridden ternary param
  localparam e_t L3 = PKP;     // E6 read of a package ternary param
endmodule

module v5_vrgg1;
  import p_v5::*;
  // E2's override actual is ITSELF a ternary over enum members
  dut_v5 #(.OV((1'b1) ? p_v5::E_B : p_v5::E_A)) u ();
endmodule
