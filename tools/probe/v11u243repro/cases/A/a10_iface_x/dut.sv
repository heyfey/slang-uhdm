// § thisNetSurelogAnchor243
// an interface and a program importing two packages (out-of-body methods)
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
interface ifc;
  import p2::*;
  import p1::*;
  logic a;
endinterface
program prg;
  import p2::*;
  import p1::*;
endprogram
module top;
  ifc i();
  prg g();
endmodule
