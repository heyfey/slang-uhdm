// § dottedCallHpSpansInvocation294
// get_inst_coverage() on a coverpoint
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.cp.get_inst_coverage(); endtask
  endclass
endmodule
