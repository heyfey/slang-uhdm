package ph;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sh_t;
endpackage
module f_real(output real o); parameter real P = 0.0; assign o = P; endmodule
module f_nd(output int o); parameter P = 1; assign o = P; endmodule
module f_pa(output logic [1:0][3:0] o); parameter logic [1:0][3:0] P = 0; assign o = P; endmodule
module f_bu(output byte unsigned o); parameter byte unsigned P = 0; assign o = P; endmodule
module top;
  parameter ph::sh_t C = 8'b10100101;
  real r1;
  int  a1;
  logic [1:0][3:0] b1;
  byte unsigned c1;
  f_real #(.P(C.g)) i1 (.o(r1));
  f_nd   #(.P(C.g)) i2 (.o(a1));
  f_pa   #(.P(C.g)) i3 (.o(b1));
  f_bu   #(.P(C.g)) i4 (.o(c1));
endmodule
