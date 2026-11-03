// § pkgQualCaReadValueForm475
package a;
  typedef logic [3:0] t;
  parameter t PA = 4;
  parameter int PI = 3;
  parameter logic [3:0] PL = 4'd2;
endpackage
module top(output logic [3:0] y, output logic [3:0] z, output logic [3:0] w);
  assign y = a::PA;
  assign z = a::PI;
  assign w = a::PL;
endmodule
