// § dottedCallHpSpansInvocation294
// a coverpoint call as a system-call argument
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    task t(); $display("%f", cg.cp.get_coverage()); endtask
  endclass
endmodule
