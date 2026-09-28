// § castOperandLeafElab193 § connCastTsNamedByPort193
module sub (input [6:0] d, input [6:0] e, output logic [7:0] o);
  assign o = 8'(d) | 8'(e);
endmodule
module dut (input logic [9:0] i, output logic [7:0] o1, output logic [7:0] o2);
  logic [9:0] r;
  assign r = i;
  sub u1 (7'(r), 7'(r[9:3]), o1);
  sub u2 (7'(r) + 7'd1, r[6:0], o2);
endmodule
