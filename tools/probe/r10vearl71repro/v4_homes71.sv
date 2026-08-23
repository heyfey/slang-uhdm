// r10v71 arm v4 — MEASUREMENT ONLY.  Non-module HOMES (interface, program) and
// the same package-parameter bounds in cont_assign / bit-select / procedural
// positions that this law must NOT reach.
package ph_v71;
  parameter  int HP = 16;
  localparam int HL = 12;
endpackage

interface ifv71 #(parameter int IW = 8) (input logic clk);
  logic [63:0] d;
endinterface

module lhv71 (
  input [63:0] h0, input [63:0] h1, input [63:0] h2, input [63:0] h3,
  input [63:0] h4, input [63:0] h5);
endmodule

module inner_v71 import ph_v71::*; (input [63:0] s, output logic [63:0] q);
  for (genvar gg = 0; gg < 2; gg++) begin: gni
    lhv71 i_deep (.h0(s[63:HP]), .h1(s[HP:0]), .h2(s[63:HL]),
                  .h3(s[HP +: 4]), .h4(s[HP]), .h5(s[63:HP-1]));
  end
  assign q = s;
endmodule

module m4_v71 import ph_v71::*; (input logic clk, input [63:0] sig,
                                 output logic [63:0] o0);
  logic [63:0] w1, w2, w3;
  // cont_assign operands and bit-select indexes in a GEN scope: must NOT move
  for (genvar g = 0; g < 2; g++) begin: gca
    logic [63:0] cw;
    assign cw = sig[63:HP] ^ sig[HP:0];
    lhv71 i_ca (.h0(cw), .h1(sig[63:HP]), .h2(sig[HP]), .h3(sig[63:HL]),
                .h4(sig[HP +: 2]), .h5(sig[HP -: 2]));
  end
  // a module instantiated in a gen scope that itself instantiates in a gen scope
  for (genvar g2 = 0; g2 < 2; g2++) begin: gnest
    inner_v71 i_in (.s(sig[63:HP]), .q());
  end
  // interface instance in a gen scope, with a select bound on its port
  for (genvar g3 = 0; g3 < 2; g3++) begin: gif2
    ifv71 #(.IW(HP)) i_if (.clk(clk));
  end
  // procedural + always positions
  always_comb begin
    w1 = sig[63:HP];
    w2 = sig[HP:0];
    w3 = sig[HP];
  end
  assign o0 = w1 ^ w2 ^ w3;
endmodule

program pgv71 import ph_v71::*; (input [63:0] sig);
  logic [63:0] r;
  initial r = sig[63:HP];
endprogram
