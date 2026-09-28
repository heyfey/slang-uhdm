// § pkgPatMemberReadAtValue195 — v11u195 fresh: a macro-born member value from an included header, and the pattern in another root file
package p;
  localparam int W = q::B.D;
  localparam int V = q::B.A;
endpackage
module top (input logic [p::W+p::V-1:0] i, output logic o);
  assign o = i[0];
endmodule
