// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
endpackage
package q;
  typedef logic [p::W-1:0] t_t;
endpackage
module top(output logic o);
  q::t_t x;
  assign x = '0;
  assign o = x[0];
endmodule
