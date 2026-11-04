// § ndaRangeQueryFold216 — $high of an input in a net initializer (v11u212 e09)
module dut (input logic [5:2] i, output logic [3:0] o);
  wire [3:0] w = $high(i);
  assign o = w;
endmodule
