package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [7:0] X = { 4'(A), 4'(B) };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
