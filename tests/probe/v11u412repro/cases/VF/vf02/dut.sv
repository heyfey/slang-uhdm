// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  task f(); endtask
endpackage
module top(output int o);
  import p2::*;
  import p::*;
  assign o = 1;
endmodule
