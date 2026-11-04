module top(input logic a, output logic [7:0] o);
`ifndef SYNTHESIS
  // synthesis translate_off
  initial $display("sim");
  // synthesis translate_on
`endif
  assign o[0] = a;
`ifndef SYNTHESIS
  // synthesis translate_off
  initial $display("sim2");
  // synthesis translate_on
`endif
  assign o[1] = ~a;
  assign o[2] = a;
  assign o[7:3] = '0;
endmodule
