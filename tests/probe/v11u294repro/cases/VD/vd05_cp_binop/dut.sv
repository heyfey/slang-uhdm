// § dottedCallHpSpansInvocation294
// a coverpoint call in an operation and a user-call argument
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    function real h(real v); return v; endfunction
    task t(); r = cg.cp.get_coverage() + h(cg.cp2.get_coverage()); endtask
  endclass
endmodule
