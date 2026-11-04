// § pkgQualCaReadValueForm475
package a;
  parameter logic [5:0] P = 6'd33;
endpackage
module top(output logic [5:0] y);
  assign y = a::P;
endmodule
