// § ppMacroBodyLines160
`define A(n) wire arr_``n = 1'b0;
module top (output logic y);
  `A(abcd) assign y = arr_abcd;
endmodule
