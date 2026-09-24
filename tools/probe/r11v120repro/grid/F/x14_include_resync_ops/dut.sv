module top(input logic [3:0] a, input logic [3:0] b, output logic [7:0] o);
`ifndef SYNTHESIS
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
`endif
  assign o[0] = a[0] & b[0];
  assign o[1] = a[1] | b[1];
`include "inc.svh"
  assign o[4] = a[2] & b[3];
  assign o[5] = a[3] ^ b[1];
  assign o[7:6] = a[1:0] + b[1:0];
endmodule
