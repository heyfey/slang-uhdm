// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  property p_a(x);
    @(posedge clk) x |-> ##1 !x;
  endproperty
  a_p: assert property (p_a(a));
endmodule
module tb;
  logic clk, a;
  for (genvar i = 0; i < 1; i++) begin : g
    chk u_c(.clk(clk), .a(a));
  end
endmodule
