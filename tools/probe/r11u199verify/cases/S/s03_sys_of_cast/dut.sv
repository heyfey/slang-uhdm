// § connSysCallArgDefNet193 § castOperandLeafElab193 § connCastTsNamedByPort193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) + 8'(e);
endmodule
module dut (input logic [9:0] i, output logic [7:0] o);
  logic [9:0] r;
  assign r = i;
  sub u (.d($signed(7'(r))), .e($unsigned(7'(r) + 7'd1)), .o(o));
endmodule
