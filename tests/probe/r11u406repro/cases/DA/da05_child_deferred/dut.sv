// § deferredAssertItemDropped406
module child(input logic a);
  assert final (a);
  always_comb assert #0 (a);
endmodule
module top;
  logic x;
  child c(.a(x));
endmodule
