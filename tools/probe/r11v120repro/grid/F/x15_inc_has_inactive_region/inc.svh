`ifndef SYNTHESIS
  // synopsys translate_off
  initial $display("sim");
  // synopsys translate_on
`endif
  assign o[1] = a[1] | b[1];
  assign o[2] = a[2] ^ b[2];
  assign o[3] = a[3] & b[0];
