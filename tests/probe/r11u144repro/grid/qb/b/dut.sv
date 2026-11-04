// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
module top(output logic o);
  logic [p::W-1:0] x;
  assign x = '0;
  assign o = x[0];
endmodule
