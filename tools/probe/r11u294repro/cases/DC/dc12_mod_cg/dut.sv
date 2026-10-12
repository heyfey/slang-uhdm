// § dottedCallHpSpansInvocation294
// a module-scope covergroup coverpoint call in an initial block
module top(input logic clk);
  int q; real r;
  covergroup cg @(posedge clk); cp : coverpoint q; endgroup
  cg inst = new();
  initial r = inst.cp.get_coverage();
endmodule
