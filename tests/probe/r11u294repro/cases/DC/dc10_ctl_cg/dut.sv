// § dottedCallHpSpansInvocation294
// CONTROL: the covergroup get_coverage() (one name before the call)
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.get_coverage(); endtask
  endclass
endmodule
