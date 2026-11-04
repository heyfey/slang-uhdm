// § pkgQualBoundSpanQualifier192
`include "pkg.svh"
`define LOC_PS p::S
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  assign y1 = x[`PS:0];
  assign y2 = `SEL(x);
  assign y3 = x[`LOC_PS:0];
  assign y4 = {1'b0, x[31:`PS]};
endmodule
