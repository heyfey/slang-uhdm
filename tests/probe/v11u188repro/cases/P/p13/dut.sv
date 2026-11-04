// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endmodule
module mid(input logic clk, input logic a);
  for (genvar i = 0; i < 1; i++) begin : gl
    chk u_c(.clk(clk), .a(a));
  end
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule
