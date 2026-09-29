// § ndaRangeQueryFold216 — unpacked-array operands: $high / $low / $right of an ascending and a descending unpacked dimension (n12's $left decline, other queries)
module dut (output logic [7:0] o1, output logic [7:0] o2, output logic [7:0] o3);
  logic [3:0] u [0:7];
  logic [3:0] d [9:2];
  wire [7:0] w1 = $high(u);
  wire [7:0] w2 = $low(d);
  wire [7:0] w3 = $right(d);
  assign o1 = w1;
  assign o2 = w2;
  assign o3 = w3;
endmodule
