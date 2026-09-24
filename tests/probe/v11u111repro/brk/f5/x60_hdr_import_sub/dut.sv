package p1;
  typedef enum logic [3:0] { A = 4'h3, B = 4'h7 } e_t;
  parameter logic [3:0] C = 4'h2;
  parameter logic [7:0] X = { C, A };
endpackage
module sub import p1::*; (input logic [7:0] i, output logic o);
  assign o = (i == X);
endmodule
module dut (input logic [7:0] i, output logic o, output logic o2);
  sub u (.i(i), .o(o));
  sub v (.i(~i), .o(o2));
endmodule
