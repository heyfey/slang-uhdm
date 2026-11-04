// § propAssertLastInstPath188
module chk(input logic clk, input logic a);
  property p_a;
    @(posedge clk) a |-> ##1 !a;
  endproperty
  a_p: assert property (p_a) else $display("bad");
endmodule
module tb;
  logic clk, a;
  chk u_direct(.clk(clk), .a(a));
endmodule
