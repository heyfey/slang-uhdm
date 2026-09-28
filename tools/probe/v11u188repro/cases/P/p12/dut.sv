// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  sequence s_a;
    a ##1 !a;
  endsequence
  property p_a;
    @(posedge clk) s_a;
  endproperty
  a_p: assert property (p_a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule
