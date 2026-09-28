// § ndaRangeQueryFold216 — the same bound text W-1 on two declarations and a port; two queries onto nets of different widths
module dut #(parameter int W = 6) (input logic [W-1:0] i, output logic [7:0] o, output logic [3:0] o2);
  logic [W-1:0] j;
  wire [7:0] w = $high(i);
  wire [3:0] x = $high(j);
  wire [3:0] y = $high(i);
  assign o = w;
  assign o2 = x ^ y;
endmodule
