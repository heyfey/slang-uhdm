`define INV(x) (~(x))
module top(input logic a, output logic [7:0] o);
`ifndef SYNTHESIS
  // pragma translate_off
  // pragma translate_on
`endif
  assign o[0] = `INV(a); assign o[1] = a;
  assign o[2] = a;
  assign o[7:3] = '0;
endmodule
