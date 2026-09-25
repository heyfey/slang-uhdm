// § rangeQueryDeclNetSize164 — $high onto a part of a declared wire
module top ();
  logic [5:0] a;
  wire [7:0] w;
  assign w[3:0] = $high(a);
endmodule
