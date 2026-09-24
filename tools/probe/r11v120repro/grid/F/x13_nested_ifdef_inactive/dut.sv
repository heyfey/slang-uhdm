module top(input logic a, output logic [3:0] o);
`ifndef SYNTHESIS
 `ifdef BAR
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
 `endif
`endif
  assign o[0] = a;
  assign o[1] = ~a;
  assign o[2] = a;
  assign o[3] = ~a;
endmodule
