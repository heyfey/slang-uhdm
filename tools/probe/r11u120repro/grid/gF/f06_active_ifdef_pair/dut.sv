module top(input logic a, output logic [7:0] o);
`ifdef SYNTHESIS
  // pragma translate_off
  initial $display("sim");
  // pragma translate_on
`endif
  assign o[0] = a;
  assign o[1] = ~a;
  assign o[7:2] = '0;
endmodule
