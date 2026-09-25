// § ppMacroBodyLines160
`define MSG(s) \
  initial $display(`"s`"); \
  assign y = 1'b1;
module top (output logic y);
  `MSG(hello)
endmodule
