// § castOperandLeafElab193 § connCastTsNamedByPort193
package pk;
  parameter logic [9:0] P = 10'h155;
endpackage
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) + 8'(e);
endmodule
module dut import pk::*; (input logic [9:0] i, output logic [7:0] o1, output logic [7:0] o2);
  logic [9:0] r;
  assign r = i;
  sub u1 (.d(7'(pk::P)), .e(7'(r)), .o(o1));
  sub u2 (.d(7'(P ^ r)), .e(7'(r)), .o(o2));
endmodule
