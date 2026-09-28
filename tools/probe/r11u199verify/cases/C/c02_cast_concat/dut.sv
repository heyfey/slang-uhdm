// § castOperandLeafElab193 § connCastTsNamedByPort193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) ^ 8'(e);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r, s;
  assign r = i;
  assign s = ~i;
  sub u (.d(7'({r, s})), .e(7'({2{r}})), .o(o));
endmodule
