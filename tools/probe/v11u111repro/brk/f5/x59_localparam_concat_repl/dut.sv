package p1;
  typedef enum logic [1:0] { A = 2'h1, B = 2'h2 } e_t;
  localparam int N = 2;
  localparam logic [7:0] X = { N{A, B} };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
