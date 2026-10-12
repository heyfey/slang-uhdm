// § dottedCallHpSpansInvocation294
// a coverpoint call with arguments
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    task t(); int a, b; r = cg.cp.get_coverage(a, b); endtask
  endclass
endmodule
