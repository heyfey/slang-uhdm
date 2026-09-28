// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m1(.clk(clk), .a(a));
  mid u_m2(.clk(clk), .a(a));
endmodule
