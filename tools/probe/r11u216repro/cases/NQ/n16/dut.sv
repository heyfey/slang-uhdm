// § ndaRangeQueryFold216 — a CRLF file: $high and $right in net initializers
module dut (input logic [5:2] i, output logic [3:0] o, output logic [3:0] o2);
  wire [3:0] w = $high(i);
  wire [3:0] x = $right(i);
  assign o = w;
  assign o2 = x;
endmodule
