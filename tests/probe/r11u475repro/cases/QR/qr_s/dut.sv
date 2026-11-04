// § pkgQualCaReadValueForm475
package a;
  parameter logic signed [5:0] P = -6'sd3;
endpackage
module top(output logic [5:0] y);
  assign y = a::P;
endmodule
