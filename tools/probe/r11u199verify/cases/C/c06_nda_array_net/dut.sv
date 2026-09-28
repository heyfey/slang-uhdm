// § castOperandLeafElab193
module sub (input logic [9:0] i, output logic [6:0] o1, output logic [6:0] o2);
  logic [9:0] r;
  assign r = i;
  wire [6:0] w [2] = '{7'(r), 7'(r >> 3)};
  wire signed [6:0] v = signed'(7'(r));
  assign o1 = w[0] ^ w[1];
  assign o2 = v;
endmodule
module dut (input logic [9:0] i, output logic [6:0] o1, output logic [6:0] o2);
  sub u (.*);
endmodule
