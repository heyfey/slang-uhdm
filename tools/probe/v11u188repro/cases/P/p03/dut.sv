// § propAssertLastInstPath188
module chk1(input logic clk, input logic a);
  a1: assert property (@(posedge clk) a);
endmodule
module chk2(input logic clk, input logic b);
  property p_b;
    @(posedge clk) b |=> !b;
  endproperty
  a2: assert property (p_b);
endmodule
module mid(input logic clk, input logic a);
  chk1 u_c1(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
  chk2 u_c2(.clk(clk), .b(a));
endmodule
