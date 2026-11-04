// § hpVsParenBoundPretty453
module top;
  parameter int W = 4;
  typedef struct packed { logic [3:0][7:0] pg; } t_s;
  t_s [1:0] tq;
  logic [1:0] o;
  assign o = tq[1].pg[1][(W > 2 ? 3 : 1):(W > 2 ? 2 : 0)];
endmodule
