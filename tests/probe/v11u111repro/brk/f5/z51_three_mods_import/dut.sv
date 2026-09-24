package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [7:0] X = { 4'h1, A };
  parameter logic [7:0] Y = { B, 4'h2 };
endpackage
module m1 (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X);
endmodule
module m2 (input logic [7:0] i, output logic o);
  import p1::X;
  assign o = (i == X);
endmodule
module dut (input logic [7:0] i, output logic o, output logic p, output logic q);
  import p1::*;
  m1 a (.i(i), .o(o));
  m2 b (.i(i), .o(p));
  assign q = (i == Y);
endmodule
