// § dottedCallHpSpansInvocation294
// a coverpoint get_coverage() under an operation
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.cp.get_coverage() + 1.0; endtask
  endclass
endmodule
