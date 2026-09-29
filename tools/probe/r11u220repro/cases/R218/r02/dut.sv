// § importCloneSharesHomeReturn218
package p1;
  virtual class b; pure virtual function int g(); endclass
  class c extends b;
    extern function int g();
    extern function int h();
  endclass
  function int c::h(); return g(); endfunction
  function int c::g(); return 4; endfunction
endpackage
package p2;
  import p1::*;
endpackage
package p3;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  import p3::*;
  assign o = 1;
endmodule
