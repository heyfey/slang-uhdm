// § ppMacroBodyLines160
`define R(n) logic r_``n = 1'b0; wire q_``n = r_``n;
module top (output logic y);
  `R(abc) assign y = q_abc;
endmodule
