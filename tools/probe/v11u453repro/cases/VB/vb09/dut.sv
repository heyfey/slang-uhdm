// § hpVsParenBoundPretty453
package p; parameter int W = 4; endpackage
module top;
  typedef struct packed { logic [3:0][7:0] pg; } t_s;
  t_s [1:0] tq;
  logic [1:0] o;
  assign o = tq[1].pg[1][(p::W-1):(p::W-2)];
endmodule
