// § dottedCallHpSpansInvocation294
// a coverpoint get_coverage() as a $display argument
module top;
  class c;
    int q;
    covergroup cg; cp : coverpoint q; endgroup
    function new(); cg = new(); endfunction
    task t(); $display("%f", cg.cp.get_coverage()); endtask
  endclass
endmodule
