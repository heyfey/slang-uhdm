// § dottedCallHpSpansInvocation294
// a coverpoint call in an if condition
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    task t(); if (cg.cp.get_coverage() > 1.0) r = 1; endtask
  endclass
endmodule
