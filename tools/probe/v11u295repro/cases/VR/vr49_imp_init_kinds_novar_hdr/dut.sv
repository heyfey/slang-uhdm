// § rawEndLineModel295
`include "hdr.svh"
package p;
  logic a = `H;
  bit b = `H;
  int c = `H;
  byte d = `H;
  integer e = `H;
  logic signed [3:0] f = `H;
  reg g = `H;
  logic [1:0] k [`N];
  int m [`N];
  bit [3:0] n [0:`N];
endpackage
module top(output logic [7:0] o);
  import p::*;
  assign o = {a, b, c[0], d[0], e[0], f[0], g, 1'b0 ^ k[0][0] ^ m[0][0] ^ n[0][0]};
endmodule
