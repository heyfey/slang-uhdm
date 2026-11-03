// § pkgQualCaReadValueForm475
// a qualified read of a reference chain and a signed decimal
package p;
  parameter logic [5:0] Q = 6'd33;
  parameter logic [5:0] P = Q;
  parameter logic signed [5:0] S = 6'sd5;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  assign y = p::P;
  assign z = p::S;
endmodule
