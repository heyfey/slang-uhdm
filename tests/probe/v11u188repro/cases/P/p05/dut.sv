// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  default clocking cb @(posedge clk); endclocking
  property p_a;
    a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
  c_p: cover property (p_a);
endmodule
module mid(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_m(.clk(clk), .a(a));
endmodule
