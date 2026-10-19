// § deferredAssertItemDropped406
module child(input logic a);
  generate
    assert final (a);
  endgenerate
  always_comb begin end
endmodule
module top;
  logic x;
  child c1(.a(x));
  child c2(.a(x));
endmodule
