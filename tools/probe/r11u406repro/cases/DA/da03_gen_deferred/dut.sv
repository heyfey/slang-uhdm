// § deferredAssertItemDropped406
module top;
  logic a;
  if (1) begin : g
    assert final (a);
  end
  for (genvar i = 0; i < 2; i++) begin : h
    assert #0 (a);
  end
endmodule
