module top(input logic a, output logic [3:0] o);
`ifndef SYNTHESIS
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
`endif
  assign o[0] = a;
`include "inc.svh"
  assign o[2] = a;
  assign o[3] = ~a;
endmodule
