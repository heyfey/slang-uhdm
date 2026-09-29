// § importCloneSharesHomeReturn218
package p1;
  class a;
    extern function int f();
  endclass
  class b;
    extern function int f();
  endclass
  function int a::f(); return 1; endfunction
  function int b::f(); return 2; endfunction
endpackage
package p2; import p1::*; endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
