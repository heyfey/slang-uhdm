package pg;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sg_t;
  parameter sg_t PC = 8'b11000011;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module top;
  parameter logic [3:0] K = 4'b1010;
  parameter pg::sg_t C1 = {K, 4'b0101};
  parameter pg::sg_t C2 = 8'b10100101;
  int a1, a2, a3, a4;
  f_int #(.P(C1.g)) i1 (.o(a1));
  f_int #(.P(C2.g)) i2 (.o(a2));
  f_int #(.P(pg::PC.g)) i3 (.o(a3));
  f_int #(.P(C1.h)) i4 (.o(a4));
endmodule
