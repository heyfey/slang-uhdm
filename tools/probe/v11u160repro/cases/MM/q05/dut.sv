// § ppMacroBodyLines160
`define M(n) \
  assign n = 1'b1; \
  localparam int L = `__LINE__; assign v = L[0];
module top (output logic y, output logic v);
  `M(y)
endmodule
