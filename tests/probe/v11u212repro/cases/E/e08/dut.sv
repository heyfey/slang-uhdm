// § ndaSysCallNetTs212 — verifier: $bits of an input in a net initializer
module dut (input logic [5:0] i, output logic [7:0] o);
  wire [7:0] w = $bits(i);
  assign o = w;
endmodule
