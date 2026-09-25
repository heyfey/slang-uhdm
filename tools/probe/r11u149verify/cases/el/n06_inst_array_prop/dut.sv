// § elabCloneInstTreeUnstored144 (--elabuhdm)
module chk(input logic clk, input logic a);
  property p_a; @(posedge clk) a |-> ##1 !a; endproperty
  assert property (p_a);
endmodule
module dut(input logic clk, input logic [1:0] a);
  chk u[1:0] (.clk(clk), .a(a));
endmodule
