// § rawEndLineModel295
`include "hdr.svh"
module top(output logic [7:0] o);
  logic a = `H;
  bit b = `H;
  int c = `H;
  byte d = `H;
  integer e = `H;
  logic signed [3:0] f = `H;
  reg g = `H;
  shortint j = `H;
  assign o = {a, b, c[0], d[0], e[0], f[0], g};
endmodule
