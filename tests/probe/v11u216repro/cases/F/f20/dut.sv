// § ndaRangeQueryFold216 — a negative arithmetic bound 1-3 ($low is -2) onto an 8-bit net
module dut (output logic [7:0] o);
  logic [3:1-3] a;
  wire [7:0] w = $low(a);
  assign o = w;
endmodule
