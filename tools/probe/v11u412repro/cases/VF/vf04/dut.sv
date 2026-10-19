// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  function int f(); return 2; endfunction
endpackage
package p3;
  function int f(); return 3; endfunction
  function int h(); return 4; endfunction
endpackage
module top(output int o);
  import p2::f;
  import p::*;
  import p3::*;
  assign o = f() + h();
endmodule
