// § dottedCallHpSpansInvocation294
// a coverpoint get_coverage() as an assignment right side (the a3_builtins shape)
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.cp.get_coverage(); endtask
  endclass
endmodule
