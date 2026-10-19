// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  function int f(); return 2; endfunction
  function int g(); return 3; endfunction
endpackage
module top(output int o);
  import p::*;
  import p2::*;
  assign o = p2::f() + g();
endmodule
