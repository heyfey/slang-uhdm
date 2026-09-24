`define ZERO 1'b0
module top(input logic a, output logic [7:0] o);
`ifndef SYNTHESIS
  // pragma translate_off
  initial $display("sim");
  // pragma translate_on
`endif
  assign o[0] = a;
  assign o[1] = `ZERO;
  assign o[2] = a;
  assign o[7:3] = '0;
endmodule
