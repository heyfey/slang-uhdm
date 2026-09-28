// § ndaRangeQueryFold216 — a range split over lines, and a bound under an inactive-branch neighbour
module dut (input logic [
    5
    :2] i, output logic [3:0] o, output logic [3:0] o2);
`ifdef NOT_DEFINED
  wire [3:0] w = $low(i);
`else
  wire [3:0] w = $high(i);
`endif
  wire [3:0] x = $left(
      i);
  assign o = w;
  assign o2 = x;
endmodule
