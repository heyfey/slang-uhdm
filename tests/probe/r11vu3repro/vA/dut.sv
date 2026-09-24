package pa;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } inner_t;
  typedef struct packed {
    inner_t          m_in;
    logic [1:0][3:0] m_pa;
    logic [7:0]      m_v8;
  } sa_t;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module f_l8(output logic [7:0] o); parameter logic [7:0] P = 0; assign o = P; endmodule
module top;
  parameter pa::sa_t C = 24'b000100100011010010101010;
  int a1, a2, a3;
  logic [7:0] b1, b2;
  f_int #(.P(C.m_in)) i1 (.o(a1));
  f_int #(.P(C.m_pa)) i2 (.o(a2));
  f_int #(.P(C.m_v8)) i3 (.o(a3));
  f_l8  #(.P(C.m_in)) i4 (.o(b1));
  f_l8  #(.P(C.m_pa)) i5 (.o(b2));
endmodule
