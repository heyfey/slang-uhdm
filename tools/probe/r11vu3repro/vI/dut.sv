package pi;
  typedef struct packed { logic [79:0] w; logic [3:0] s; } si_t;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module top;
  parameter pi::si_t C = 84'h123456789abcdef01234A;
  int a1;
  f_int #(.P(C.s)) i1 (.o(a1));
endmodule
