// § deferredAssertItemDropped406
module top;
  logic a;
  always_comb begin
    assert final (a);
    assert #0 (a);
  end
  initial assert (a);
  assert property (@(posedge a) a);
endmodule
