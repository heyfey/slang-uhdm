// § propAssertLastInstPath188 + § bindDisplayTargetParent188
module dut(input logic clk, input logic a);
endmodule
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a) else $display("bad");
endmodule
bind dut chk u_chk(.clk(clk), .a(a));
module mid(input logic clk, input logic a);
  dut u_dut(.clk(clk), .a(a));
endmodule
module tb;
  logic clk, a;
  mid u_mid(.clk(clk), .a(a));
endmodule
