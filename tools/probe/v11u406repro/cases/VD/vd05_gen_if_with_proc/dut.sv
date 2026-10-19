// § deferredAssertItemDropped406
module top(input logic a, output logic o);
  if (1) begin : g
    assert final (a);
    always_comb o = a;
  end
endmodule
