module sub(input logic a, output logic [1:0] o);
`ifndef SYNTHESIS
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
`endif
  assign o[0] = a;
  assign o[1] = ~a;
endmodule
