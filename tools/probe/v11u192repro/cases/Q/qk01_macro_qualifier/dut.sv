// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
`define PK p
`define NM S
`define RNG(a) a:0
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  assign y1 = x[`PK::S:0];
  assign y2 = x[p::`NM:0];
  assign y3 = x[`RNG(p::S)];
  assign y4 = x[p ::S:0];
endmodule
