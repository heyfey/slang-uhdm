// § pkgQualCaReadValueForm475
package a;
  parameter logic [3:0] P = 4'b1010;
endpackage
module top(output logic [3:0] y);
  assign y = a::P;
endmodule
