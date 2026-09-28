// § propAssertLastInstPath188 (control: judge-unequal or top-bound at the base)
module dut(input logic clk, input logic a);
endmodule
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a) else $display("bad");
endmodule
bind dut chk u_chk(.clk(clk), .a(a));
module tb;
  logic clk, a, b;
  dut u_one(.clk(clk), .a(a));
  dut u_two(.clk(clk), .a(b));
endmodule
