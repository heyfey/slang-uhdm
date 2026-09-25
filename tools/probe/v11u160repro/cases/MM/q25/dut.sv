// § ppMacroBodyLines160
`define MSG(v) \
  initial $display("%s %d", `__FILE__, `__LINE__); \
  assign y = v;
module top (output logic y);
  `MSG(1'b1)
endmodule
