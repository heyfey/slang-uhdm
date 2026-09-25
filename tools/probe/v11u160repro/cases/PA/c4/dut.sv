// § ppMacroBodyLines160
`define A(n) \
  wire arr_``n = 1'b0; \
  assign y = arr_``n;
module top (output logic y);
  `A(abcd)
endmodule
