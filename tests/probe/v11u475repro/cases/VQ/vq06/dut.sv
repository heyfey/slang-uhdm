// § pkgQualCaReadValueForm475
// a qualified read into a narrower and a wider left side
package p;
  parameter logic [5:0] P = 6'd33;
  parameter Q = 'd9;
endpackage
module top(output logic [3:0] y, output logic [15:0] z, output logic [15:0] w);
  assign y = p::P;
  assign z = p::P;
  assign w = p::Q;
endmodule
