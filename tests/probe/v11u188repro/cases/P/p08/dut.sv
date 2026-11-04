// § propAssertLastInstPath188
module dut(input logic clk, input logic a);
endmodule
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a);
endmodule
module wrap(input logic clk, input logic a);
  chk u_c(.clk(clk), .a(a));
endmodule
bind dut wrap u_w(.clk(clk), .a(a));
module tb;
  logic clk, a;
  dut u_dut(.clk(clk), .a(a));
endmodule
