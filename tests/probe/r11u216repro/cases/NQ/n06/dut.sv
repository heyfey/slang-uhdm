// § ndaRangeQueryFold216 — $size of a packed input in a net initializer
module dut (input logic [5:2] i, output logic [7:0] o);
  wire [7:0] w = $size(i);
  assign o = w;
endmodule
