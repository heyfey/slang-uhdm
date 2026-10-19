// § deferredAssertItemDropped406
module top(input logic clk, input logic a, input logic b, output logic o);
  always_ff @(posedge clk) begin
    assert (a);
    o <= a;
  end
  a1: assert property (@(posedge clk) a |-> b);
  c0: cover #0 (a && b);
  always_comb assert #0 (b);
endmodule
