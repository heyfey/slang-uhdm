// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = 3;
endpackage
module sub (input logic [3:0] a, output logic [3:0] b);
  assign b = a;
endmodule
module mid (input logic [31:0] x, output logic [3:0] y);
  sub u (.a(x[p::S:0]), .b(y));
endmodule
module top (input logic [31:0] x, output logic [3:0] y);
  mid m (.*);
endmodule
