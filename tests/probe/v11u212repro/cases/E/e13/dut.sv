// § ndaSysCallNetTs212 — verifier: a tri net and a wand net with $unsigned initializers
module dut (input logic signed [5:0] i, output logic [5:0] o, output logic [5:0] o2);
  tri [5:0] t = $unsigned(i);
  wand [5:0] a = $unsigned(i);
  assign o = t;
  assign o2 = a;
endmodule
