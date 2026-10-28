// § hpVsParenBoundPretty453
module top;
  typedef struct packed { logic [3:0][7:0] pg; } t_s;
  t_s [1:0] tq;
  logic [1:0] o;
  int ix;
  always_comb o = tq[1].pg[1][(ix*2)+:2];
endmodule
