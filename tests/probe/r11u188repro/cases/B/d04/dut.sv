// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  property p_a(x);
    @(posedge clk) x |-> ##1 !x;
  endproperty
  a_p: assert property (p_a(a));
endmodule
module tb;
  logic clk, a;
  chk u_c[0:0] (.clk(clk), .a(a));
endmodule
