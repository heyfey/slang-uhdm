package pk;
  typedef struct packed { logic [15:0] a; logic [15:0] b; } s_t;
  parameter s_t P_S = '{a: 16'h1, b: 16'h2};
  parameter s_t P_C = {16'h1, 16'h2};
endpackage
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z, output logic [15:0] z2);
  assign z = x & P_C;
  assign z2 = P_C.a ^ P_S.b;
endmodule
