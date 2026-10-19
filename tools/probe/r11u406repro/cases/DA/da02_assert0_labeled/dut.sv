// § deferredAssertItemDropped406
module top;
  logic a, b;
  l1: assert #0 (a == b) else $error("x");
  assume #0 (a);
  cover final (b);
endmodule
