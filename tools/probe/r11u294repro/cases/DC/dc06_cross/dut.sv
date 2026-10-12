// § dottedCallHpSpansInvocation294
// a cross get_coverage()
module top;
  class c;
    int q, w; real r;
    covergroup cg; a : coverpoint q; b : coverpoint w; x : cross a, b; endgroup
    function new(); cg = new(); endfunction
    task t(); r = cg.x.get_coverage(); endtask
  endclass
endmodule
