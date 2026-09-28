// § ndaRangeQueryFold216 — $low, $left, $right of an ascending input in net initializers
module dut (input logic [2:6] i, output logic [7:0] o1, o2, o3);
  wire [7:0] a = $low(i);
  wire [7:0] b = $left(i);
  wire [7:0] c = $right(i);
  assign o1 = a;
  assign o2 = b;
  assign o3 = c;
endmodule
