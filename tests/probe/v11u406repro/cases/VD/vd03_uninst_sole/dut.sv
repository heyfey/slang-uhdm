// § deferredAssertItemDropped406
module lonely(input logic a);
  assert final (a);
endmodule
module top(input logic a, output logic o);
  assign o = a;
  if (0) begin : never
    lonely l(a);
  end
endmodule
