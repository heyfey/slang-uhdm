module top(input logic a, output logic y, output logic z);
  assign y = a;
`ifndef SYNTHESIS
  // synopsys translate_off
`endif
  initial $display("sim");
  // synopsys translate_on
  assign z = ~a;
endmodule
