// § deferredAssertItemDropped406
module top;
  logic a, b;
  initial a = 0;
  assert final (a);
  always @(a) b = a;
  cover #0 (b);
  final $display(b);
endmodule
