module top(input logic a, output logic [3:0] o);
`ifdef FOO
  assign o[3] = a;
`elsif SYNTHESIS
  assign o[3] = ~a;
`else
  // synthesis translate_off
  initial $display("x");
  // synthesis translate_on
`endif
  assign o[0] = a;
  assign o[1] = ~a;
  assign o[2] = a & o[0];
endmodule
