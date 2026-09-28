// § ndaRangeQueryFold216 — $low / $right of a parameter-sized input (bound W-1, v11u212 g13)
module dut #(parameter int W = 6) (input logic [W-1:0] i, output logic [7:0] o, output logic [7:0] o2);
  wire [7:0] l = $high(i);
  wire [7:0] r = $right(i);
  assign o = l;
  assign o2 = r;
endmodule
