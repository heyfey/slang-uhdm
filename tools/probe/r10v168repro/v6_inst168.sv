// r10v168repro/v6_inst168.sv — MEASUREMENT ONLY.
// FACE: INSTANCE COUNT.  The same package parameters (auto-numbered, based
// decimal, octal) read through ONE, TWO and THREE instances of the same module,
// through a module instantiated inside a generate loop, and through a module
// whose own parameter is OVERRIDDEN per instance with an enum member.  Every
// materialized-import copy is a separate cell, so a law that fires once per
// EMISSION rather than once per PARAMETER shows up here as a per-instance
// divergence.
package welkin_pkg;
  typedef enum { XEBEC_NIL, XEBEC_ONE, XEBEC_TWO, XEBEC_TRI } xebec_e;
  typedef enum bit [7:0]   { YAFFLE_D = 8'd33, YAFFLE_NX } yaffle_e;
  typedef enum logic [5:0] { ZORIL_O  = 6'o52, ZORIL_NX  } zoril_e;

  parameter xebec_e  i_auto = XEBEC_TRI;
  parameter yaffle_e i_bdec = YAFFLE_D;
  parameter yaffle_e i_bnxt = YAFFLE_NX;
  parameter zoril_e  i_oct  = ZORIL_O;
endpackage

module Arrish_leaf
  #(parameter welkin_pkg::xebec_e L_SEL = welkin_pkg::XEBEC_NIL)
   (input logic ck, output logic oz);
  import welkin_pkg::*;
  localparam int l_from_sel = L_SEL;
  localparam int l_from_pkg = i_auto;
  assign oz = ck ^ (l_from_sel[0] ^ l_from_pkg[0]);
endmodule

module Bicorn_one(input logic ck, output logic oz);
  import welkin_pkg::*;
  Arrish_leaf #(.L_SEL(XEBEC_ONE)) u0 (.ck(ck), .oz(oz));
endmodule

module Cantle_two(input logic ck, output logic [1:0] oz);
  import welkin_pkg::*;
  Arrish_leaf #(.L_SEL(XEBEC_ONE)) u0 (.ck(ck), .oz(oz[0]));
  Arrish_leaf #(.L_SEL(XEBEC_TWO)) u1 (.ck(ck), .oz(oz[1]));
endmodule

module Dornick_three(input logic ck, output logic [2:0] oz);
  import welkin_pkg::*;
  Arrish_leaf #(.L_SEL(XEBEC_ONE)) u0 (.ck(ck), .oz(oz[0]));
  Arrish_leaf #(.L_SEL(XEBEC_TWO)) u1 (.ck(ck), .oz(oz[1]));
  Arrish_leaf #(.L_SEL(XEBEC_TRI)) u2 (.ck(ck), .oz(oz[2]));
endmodule

module Ewer_top(input logic ck, output logic [5:0] oz);
  import welkin_pkg::*;
  Bicorn_one     ub (.ck(ck), .oz(oz[0]));
  Cantle_two     uc (.ck(ck), .oz(oz[2:1]));
  Dornick_three  ud (.ck(ck), .oz(oz[5:3]));

  // the same leaf instantiated three times inside a generate loop
  generate
    for (genvar gj = 0; gj < 3; gj++) begin : g_rep
      localparam yaffle_e g_bdec = i_bdec;
      localparam zoril_e  g_oct  = i_oct;
    end
  endgenerate
endmodule
