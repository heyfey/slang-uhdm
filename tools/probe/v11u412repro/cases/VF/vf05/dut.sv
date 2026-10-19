// § importFnNameFirstWins412
package p;
  function int f(); return 1; endfunction
endpackage
package p2;
  function int f(); return 2; endfunction
endpackage
import p::*;
import p2::*;
module top(output int o);
  assign o = p::f();
endmodule
