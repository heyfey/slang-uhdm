// § castOperandLeafElab193 § connCastTsNamedByPort193 § connSysCallArgDefNet193
module sub (input signed [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) + 8'(e);
endmodule
module dut (input logic [6:0] i, output logic [7:0] o1, output logic [7:0] o2);
  logic [6:0] r;
  logic signed [6:0] s;
  assign r = i;
  assign s = i;
  sub u1 (.d(signed'(r)), .e(unsigned'(s)), .o(o1));
  sub u2 (.d(signed'(r[6:0])), .e(unsigned'(s) + 7'd1), .o(o2));
endmodule
