// § ndaRangeQueryFold216 — controls: a query inside an expression, a two-dimensional packed operand (declined)
module dut (input logic [3:0][5:2] j, output logic [3:0] o2, o3);
  wire [3:0] b = $high(j) + 1;
  wire [3:0] c = $high(j);
  assign o2 = b;
  assign o3 = c;
endmodule
