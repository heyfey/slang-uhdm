// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  function int f(); return 2; endfunction
endpackage
module top(output int o);
  import p::*;
  import p2::*;
  function int f(); return 9; endfunction
  assign o = f();
endmodule
