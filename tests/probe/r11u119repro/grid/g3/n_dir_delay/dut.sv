`define UNUSED_M 1
module top(input logic a, output logic y, z);
  assign #1  y = a;
  assign #2     z = a;
endmodule
