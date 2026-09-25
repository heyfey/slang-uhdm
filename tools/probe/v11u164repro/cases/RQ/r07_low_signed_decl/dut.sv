// § rangeQueryDeclNetSize164 — $low onto a declared signed wire
module top ();
  logic [7:3] a;
  wire signed [3:0] w;
  assign w = $low(a);
endmodule
