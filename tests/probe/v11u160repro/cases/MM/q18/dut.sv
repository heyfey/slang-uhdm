// § ppMacroBodyLines160
`define BLK \
`ifdef NOPE \
  assign y = 1'b0; \
`endif \
  assign y = a;
module top (input logic a, output logic y);
  `BLK
endmodule
