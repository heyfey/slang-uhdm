// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 2;
endpackage
module top (input logic [7:0] a [8], output logic [7:0] b [3], output logic [2:0] c);
  assign b = a[0:p::S];
  assign c = a[0][p::S:0];
endmodule
