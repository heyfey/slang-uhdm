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
module tb;
  logic clk, a;
  if (1) begin : g
    dut u_dut(.clk(clk), .a(a));
  end
endmodule
