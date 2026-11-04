// § pkgQualCaReadValueForm475
package a;
  parameter logic [5:0] P = 'd9;
endpackage
module top(output logic [5:0] y);
  assign y = a::P;
endmodule
