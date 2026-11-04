// § ndaRangeQueryFold216 — a non-ANSI port queried in a net initializer
module dut (i, o);
  input [5:2] i;
  output [3:0] o;
  wire [3:0] w = $high(i);
  assign o = w;
endmodule
