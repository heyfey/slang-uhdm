// § ndaSysCallNetTs212 — verifier: $clog2 of a parameter in a net initializer
module dut #(parameter int N = 12) (output logic [3:0] o);
  wire [3:0] w = $clog2(N);
  assign o = w;
endmodule
