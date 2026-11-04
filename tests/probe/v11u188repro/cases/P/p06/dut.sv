// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  if (1) begin : gg
    a_g: assert property (@(posedge clk) a);
  end
  property p_a;
    @(posedge clk) a;
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
