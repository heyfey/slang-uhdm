// § thisNetSurelogAnchor243
// two modules importing two packages in opposite orders (out-of-body methods)
package p1;
  class c1;
    extern function void f();
  endclass
  function void c1::f(); $display("%p", this); endfunction
endpackage
package p2;
  class c2;
    extern function void g();
  endclass
  function void c2::g(); $display("%p", this); endfunction
endpackage
module m1;
  import p2::*;
  import p1::*;
endmodule
module m2;
  import p1::*;
  import p2::*;
endmodule
module top;
  m1 a();
  m2 b();
endmodule
