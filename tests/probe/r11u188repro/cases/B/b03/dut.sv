// § propAssertLastInstPath188 (control: judge-unequal or top-bound at the base)
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a) else $display("bad");
endmodule
module tb;
  logic clk, a;
endmodule
bind tb chk u_chk(.clk(clk), .a(a));
