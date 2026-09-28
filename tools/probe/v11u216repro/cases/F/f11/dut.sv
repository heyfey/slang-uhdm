// § ndaRangeQueryFold216 — a non-ANSI port with a signed range, two declarators in one net declaration
module dut (i, o, o2);
  input signed [6:1] i;
  output [7:0] o, o2;
  wire [7:0] w = $low(i), x = $right(i);
  assign o = w;
  assign o2 = x;
endmodule
