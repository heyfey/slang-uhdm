// § pkgQualCaReadValueForm475
// a qualified read in a child instance and in an uninstantiated module
package p;
  parameter logic [5:0] P = 6'd33;
endpackage
module sub(output logic [5:0] y);
  assign y = p::P;
endmodule
module unused(output logic [5:0] y);
  assign y = p::P;
endmodule
module top(output logic [5:0] y);
  sub u(y);
endmodule
