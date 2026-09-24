package pe;
  typedef struct packed {
    logic [31:0] m_a;
    logic [31:0] m_b;
    logic [3:0]  m_c;
  } se_t;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module f_l4(output logic [3:0] o); parameter logic [3:0] P = 0; assign o = P; endmodule
module top;
  parameter pe::se_t C = 68'h8000000140000002A;
  int a1, a2, a3;
  logic [3:0] b1;
  f_int #(.P(C.m_a)) i1 (.o(a1));
  f_int #(.P(C.m_c)) i2 (.o(a2));
  f_int #(.P(C.m_b)) i3 (.o(a3));
  f_l4  #(.P(C.m_c)) i4 (.o(b1));
endmodule
