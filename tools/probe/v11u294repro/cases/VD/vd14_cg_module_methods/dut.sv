// § dottedCallHpSpansInvocation294
// covergroup instance methods in a module through a coverpoint and a cross, inside a function and as a comparison
module top(input logic clk, input int v, w, output real r, output bit b);
  covergroup cg @(posedge clk); cp : coverpoint v; cq : coverpoint w; cx : cross cp, cq; endgroup
  cg g = new();
  function real f(); return g.cx.get_inst_coverage(); endfunction
  always @(posedge clk) begin r = f(); b = g.cq.get_coverage() >= 50.0; end
endmodule
