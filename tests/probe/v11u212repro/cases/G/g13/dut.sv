// § ndaSysCallNetTs212 — verifier: $low of a parameter-sized input in a net initializer, and $right of an input
module dut #(parameter int W = 6) (input logic [W-1:0] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] l = $low(i);
  wire [7:0] r = $right(i);
  assign o = l;
  assign o2 = r;
endmodule
