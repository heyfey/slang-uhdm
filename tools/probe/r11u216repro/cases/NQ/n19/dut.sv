// § ndaRangeQueryFold216 — a signed net initialized by $high, and a macro-written query
`define HI(x) $high(x)
module dut (input logic [5:2] i, output logic signed [3:0] o, output logic [3:0] o2);
  wire signed [3:0] w = $high(i);
  wire [3:0] x = `HI(i);
  assign o = w;
  assign o2 = x;
endmodule
