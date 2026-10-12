// § dottedCallHpSpansInvocation294
// a cross get_inst_coverage
module top;
  class c;
    int q, q2; real r; int n;
    covergroup cg; cp : coverpoint q; cp2 : coverpoint q2; cx : cross cp, cp2; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.cx.get_inst_coverage(); endtask
  endclass
endmodule
