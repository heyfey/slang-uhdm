// § propAssertLastInstPath188 (control: judge-unequal or top-bound at the base)
program prg(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endprogram
module tb;
  logic clk, a;
  prg u_p(clk, a);
endmodule
