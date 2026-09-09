package pd;
  typedef struct packed { logic [79:0] w; logic [3:0] s; } sd_t;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module f_w(output logic [79:0] o); parameter logic [79:0] P = 0; assign o = P; endmodule
module top;
  parameter pd::sd_t C = 84'h123456789abcdef012345;
  int a1;
  logic [79:0] b1;
  f_int #(.P(C.s)) i1 (.o(a1));
  f_w   #(.P(C.w)) i2 (.o(b1));
endmodule
