// § psBoundPaOwnerName192 § castOperandLeafElab193 § connCastTsNamedByPort193
package p;
  parameter int unsigned W = 5;
endpackage
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut import p::*; (input logic [9:0] i, output logic [7:0] o1, output logic [7:0] o2);
  logic [9:0] r;
  assign r = i;
  sub u1 (.d(7'(r[W:0])), .o(o1));
  sub u2 (.d(7'({r[9:W], 1'b0})), .o(o2));
endmodule
module top (input logic [9:0] i, output logic [7:0] o1, output logic [7:0] o2);
  dut d (.*);
endmodule
