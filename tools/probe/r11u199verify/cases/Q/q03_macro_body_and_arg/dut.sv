// § pkgQualBoundSpanQualifier192
`define LOWSEL(v) v[p::S:0]
`define BSEL(v, b) v[b:0]
`define PS p::S
package p;
  parameter int unsigned S = 3;
endpackage
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  assign y1 = `LOWSEL(x);
  assign y2 = `BSEL(x, p::S);
  assign y3 = x[`PS:0];
  assign y4 = `BSEL(x, `PS);
endmodule
