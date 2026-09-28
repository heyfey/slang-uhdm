// § ndaRangeQueryFold216 — $high in a scalar net initializer and a two-declarator list
module dut (input logic [5:2] i, output logic o, output logic [3:0] o2);
  wire w = $high(i), x = $low(i);
  wire [3:0] y = $high(i), z = $low(i);
  assign o = w ^ x;
  assign o2 = y ^ z;
endmodule
