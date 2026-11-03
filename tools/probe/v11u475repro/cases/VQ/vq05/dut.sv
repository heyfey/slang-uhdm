// § pkgQualCaReadValueForm475
// an explicit import read unqualified beside a qualified read
package p;
  parameter logic [5:0] P = 6'd33;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import p::P;
  assign y = P;
  assign z = p::P;
endmodule
