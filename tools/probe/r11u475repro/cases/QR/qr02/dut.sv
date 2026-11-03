// § pkgQualCaReadValueForm475
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
  parameter int PI = 3;
endpackage
module top(output logic [3:0] y, output logic [3:0] z);
  import b::*;
  assign y = b::PB;
  assign z = b::PI;
endmodule
