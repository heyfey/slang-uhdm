// § signCastSysCallLhsTs212 — verifier: a signing cast in a parameterized child instantiated with two widths
module c #(parameter int W = 4) (input logic [W-1:0] i, output logic signed [W-1:0] o);
  assign o = signed'(i);
endmodule
module dut (input logic [7:0] i, output logic [3:0] o1, output logic [7:0] o2);
  c #(4) u (.i(i[3:0]), .o(o1));
  c #(8) v (.i(i), .o(o2));
endmodule
