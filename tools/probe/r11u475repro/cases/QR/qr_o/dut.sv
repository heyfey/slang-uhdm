// § pkgQualCaReadValueForm475
package a;
  parameter logic [5:0] P = 6'o41;
endpackage
module top(output logic [5:0] y);
  assign y = a::P;
endmodule
