`define ONE(x) (x)
`define TWO 1'b1
module top(input logic a, output logic [3:0] o);
  assign o[0] = `ONE(a);
`ifndef SYNTHESIS
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
`endif
  assign o[1] = `TWO;
  assign o[2] = ~a;
  assign o[3] = `ONE(~a);
endmodule
