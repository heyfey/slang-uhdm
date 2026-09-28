// § ndaRangeQueryFold216 — two packed dimensions: $high and $left read the outer range
module dut (input logic [1:3][7:0] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] w = $high(i);
  wire [7:0] x = $left(i);
  assign o = w;
  assign o2 = x;
endmodule
