// § propAssertLastInstPath188 (a top module's own assertions: the top elab instance re-parents them)
module tb(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endmodule
