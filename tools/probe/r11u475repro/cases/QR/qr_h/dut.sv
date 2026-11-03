// § pkgQualCaReadValueForm475
package a;
  parameter logic [7:0] P = 8'h2a;
endpackage
module top(output logic [7:0] y);
  assign y = a::P;
endmodule
