// § caPsSelFullVerbatim192 § connSysCallArgDefNet193 § connCastTsNamedByPort193 § castOperandLeafElab193
package p;
  parameter int unsigned W = 3;
endpackage
module leaf (input logic [3:0] a, input logic [6:0] b, input logic [3:0] c, output logic [7:0] o);
  assign o = {a, c} ^ {1'b0, b};
endmodule
module mid import p::*; (input logic [31:0] x, output logic [7:0] o);
  logic [9:0] r;
  assign r = x[9:0];
  leaf l (.a(x[W:0]), .b(7'(r)), .c($unsigned(x[W+4:4])), .o(o));
endmodule
module top (input logic [31:0] x, output logic [7:0] o);
  mid m (.*);
endmodule
