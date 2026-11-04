// § dottedCallHpSpansInvocation294
// a coverpoint get_coverage() in an if condition
module top;
  class c;
    int q; int k;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); if (cg.cp.get_coverage() > 50.0) k = 1; endtask
  endclass
endmodule
