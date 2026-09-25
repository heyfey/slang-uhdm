// § rangeQueryDeclNetSize164 — $high onto a declared logic variable
module top ();
  logic [5:0] a;
  logic [2:0] v;
  assign v = $high(a);
endmodule
