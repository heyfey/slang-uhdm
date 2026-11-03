// § pkgQualCaReadValueForm475
package a;
  parameter logic [5:0] PD = 6'd33;
  parameter logic [7:0] PH = 8'h2a;
endpackage
module top(output logic [5:0] y, output logic [5:0] z, output logic [7:0] w);
  import a::*;
  logic [5:0] v = a::PD;
  assign y = a::PD;
  assign z = v;
  assign w = a::PH;
endmodule
