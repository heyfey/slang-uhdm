// § ndaSysCallNetTs212 — the signing cast in a child's net initializer (c06's shape without the array net)
module sub (input logic [9:0] i, output logic [6:0] o2);
  logic [9:0] r;
  assign r = i;
  wire signed [6:0] v = signed'(7'(r));
  assign o2 = v;
endmodule
module dut (input logic [9:0] i, output logic [6:0] o2);
  sub u (.*);
endmodule
