package p1;
  parameter int W = 8;
  parameter logic [7:0] X = { 4'h?, $clog2(W) };
  parameter logic [7:0] Y = { W[3:0], 4'h1 };
endpackage
module dut (input logic [7:0] i, output logic o, output logic p);
  import p1::*;
  assign o = (i ==? X);
  assign p = (i == Y);
endmodule
