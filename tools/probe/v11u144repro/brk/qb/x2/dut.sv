// § pkgTsForeignQualRefUnstored144
package p;
  localparam int W = 8;
  localparam int B = 2;
endpackage
package q;
  parameter int A = p::B + 1;
  localparam logic [p::W-1:0] L = 3;
  typedef logic [p::W-1:0][p::B-1:0] t2;
endpackage
module top(output int o);
  q::t2 x;
  assign x = '0;
  assign o = q::A + int'(q::L) + int'(x);
endmodule
