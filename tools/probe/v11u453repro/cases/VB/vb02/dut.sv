// § hpVsParenBoundPretty453
module top;
  typedef struct packed { logic [3:0][7:0] pg; } t_s;
  t_s [1:0] tq;
  logic [3:0] o;
  assign o = tq[1].pg[1][2**2-1:0];
endmodule
