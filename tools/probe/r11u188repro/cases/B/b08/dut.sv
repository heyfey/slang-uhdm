// § propAssertLastInstPath188
module dut(input logic clk, input logic a);
endmodule
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  assert property (p_a);
  cover property (p_a);
endmodule
bind dut chk u_chk(.clk(clk), .a(a));
module tb;
  logic clk, a;
  dut u_dut(.clk(clk), .a(a));
endmodule
