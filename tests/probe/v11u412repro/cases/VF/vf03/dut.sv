// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  function int f(); return 2; endfunction
endpackage
module a(output int o);
  import p::*;
  assign o = f();
endmodule
module b(output int o);
  import p2::*;
  assign o = f();
endmodule
module top(output int o1, output int o2);
  a ua(o1);
  b ub(o2);
endmodule
