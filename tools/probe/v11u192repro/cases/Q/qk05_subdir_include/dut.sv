// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
`include "inc/defs.svh"
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3);
  assign y1 = `SEL(x);
  assign y2 = `PSEL(x, p::S);
  assign y3 = `PSEL(x, `PS);
endmodule
