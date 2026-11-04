// § importCloneSharesHomeReturn218 — c11_two_methods: two out-of-block methods of two classes
package p1;
  class c;
    extern function int f();
  endclass
  class d;
    extern function string g();
  endclass
  function int c::f();
    return 1;
  endfunction
  function string d::g();
    return "g";
  endfunction
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
