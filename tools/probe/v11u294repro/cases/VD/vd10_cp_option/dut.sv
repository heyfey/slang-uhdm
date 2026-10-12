// § dottedCallHpSpansInvocation294
// a coverpoint call on a covergroup in a module and a sample call
module top(input logic clk, input int v, output real r);
  covergroup cg @(posedge clk); cp : coverpoint v; endgroup
  cg g = new();
  always @(posedge clk) begin r = g.cp.get_coverage(); g.sample(); end
endmodule
