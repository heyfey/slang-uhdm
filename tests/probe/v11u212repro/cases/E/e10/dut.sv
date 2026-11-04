// § ndaSysCallNetTs212 — verifier: two net declarators with system-call initializers in one declaration
module dut (input logic [5:0] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] a = $bits(i), b = $unsigned(i);
  assign o = a;
  assign o2 = b;
endmodule
