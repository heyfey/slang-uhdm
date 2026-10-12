// § dottedCallHpSpansInvocation294
// a coverpoint call through this. and from outside the class through a handle
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    task t(); r = this.cg.cp.get_coverage(); endtask
  endclass
  c h;
  real z;
  initial begin h = new(); z = h.cg.cp.get_coverage(); end
endmodule
