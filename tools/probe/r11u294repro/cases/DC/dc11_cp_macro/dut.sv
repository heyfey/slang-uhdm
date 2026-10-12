// § dottedCallHpSpansInvocation294
// the call through a macro
`define GC(x) x.get_coverage()
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = `GC(cg.cp); endtask
  endclass
endmodule
