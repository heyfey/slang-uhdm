// § pkgPatMemberReadAtValue195 — grid P/p13 (r11u195)
package p;
  import q::*;
  localparam int W = B.D;
endpackage
module top (input logic [p::W-1:0] i, output logic o);
  assign o = i[0];
endmodule
