// § rangeQueryDeclNetSize164 — $high = 20 of a parameter onto a declared 4-bit wire
module top ();
  parameter [20:0] a = 10;
  wire [3:0] w;
  assign w = $high(a);
endmodule
