// § dottedCallHpSpansInvocation294
// spaces before and inside the parentheses
module top;
  class c;
    int q; real r;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.cp.get_coverage ( ); endtask
  endclass
endmodule
