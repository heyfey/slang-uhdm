`define UNUSED_M 1
module top(input logic [7:0] b, output logic y1, y2);
  assign y1 = b[3]     | b[0];
  assign y2 = b[3     ] | b[1];
endmodule
