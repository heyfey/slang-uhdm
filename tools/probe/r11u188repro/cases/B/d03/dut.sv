// § propAssertLastInstPath188 (control: judge-unequal or top-bound at the base)
module chk(input logic clk, input logic a);
  sequence s_a;
    a ##1 !a;
  endsequence
  property p_a;
    @(posedge clk) s_a;
  endproperty
  a_p: assert property (p_a);
  c_p: cover property (@(posedge clk) a);
  assume property (@(posedge clk) !a);
endmodule
module tb;
  logic clk, a;
  chk u_c(.clk(clk), .a(a));
endmodule
