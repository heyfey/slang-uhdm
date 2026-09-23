package p1;
  typedef enum logic [2:0] { A = 3'h3, B = 3'h5 } e_t;
  parameter logic [3:0] X = { 1'b1, A };
  parameter logic [7:0] X2 = { X, 1'b0, B };
endpackage
module dut (input logic [7:0] i, output logic o);
  import p1::*;
  assign o = (i == X2);
endmodule
