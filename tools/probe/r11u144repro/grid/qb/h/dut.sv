// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  parameter logic [p::W-1:0] P = '0;
endpackage
module top(output logic o);
  assign o = q::P[0];
endmodule
