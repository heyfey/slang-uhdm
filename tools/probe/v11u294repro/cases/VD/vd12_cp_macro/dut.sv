// § dottedCallHpSpansInvocation294
// a coverpoint call spelled across a macro and with spaces before the parenthesis
`define COVC(g) g.cp.get_coverage
module top;
  class c;
    int q; real r, s;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = `COVC(cg)(); s = cg.cp.get_coverage  (  ); endtask
  endclass
endmodule
