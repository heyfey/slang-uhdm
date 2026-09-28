// § elabCaConstLhsSized191: one unsized hex package parameter into 1-, 7-, 33- and 65-bit left sides
package p;
  parameter U = 'h5A5;
endpackage
module m(output logic a, output logic [6:0] b, output logic [32:0] c, output logic [64:0] d);
  import p::*;
  assign a = U;
  assign b = U;
  assign c = U;
  assign d = U;
endmodule
module top(output logic o1, output logic [6:0] o2, output logic [32:0] o3, output logic [64:0] o4);
  m u(.a(o1), .b(o2), .c(o3), .d(o4));
endmodule
