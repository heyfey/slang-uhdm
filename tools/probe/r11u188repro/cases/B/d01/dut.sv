// § propAssertLastInstPath188 (control: judge-unequal or top-bound at the base)
interface ifc(input logic clk);
  logic a;
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endinterface
module tb;
  logic clk;
  ifc u_if(clk);
endmodule
