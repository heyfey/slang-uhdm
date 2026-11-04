// § netSigningTsSpan130
// case s04: the net keyword and signing come from a macro
`define SNET wire signed
module top(output logic [3:0] o);
  `SNET [3:0] s;
  assign s = 4'sd2;
  assign o = s;
endmodule
