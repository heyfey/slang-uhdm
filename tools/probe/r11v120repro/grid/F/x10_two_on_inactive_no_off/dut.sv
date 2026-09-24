module top(input logic a, output logic [3:0] o);
`ifndef SYNTHESIS
  // synopsys translate_on
  // synopsys translate_on
`endif
  assign o[0] = a;
  always_comb begin
    o[1] = ~a;
    o[2] = a;
  end
  assign o[3] = ~a;
endmodule
