// § elabCaConstLhsSized191: an unsized hex package parameter into a 16-bit LHS and an octal one into an int, two instances
package p;
  parameter X = 'h7;
  parameter Y = 'o17;
endpackage
module m(output logic [15:0] a, output int b);
  import p::*;
  assign a = X;
  assign b = Y;
endmodule
module top(output logic [15:0] o1, o3, output int o2, o4);
  m u1(.a(o1), .b(o2));
  m u2(.a(o3), .b(o4));
endmodule
