// § thisNetSurelogAnchor243
// an interface and a program importing two packages
package p1;
  class c1;
    function void f(); $display("%p", this); endfunction
  endclass
endpackage
package p2;
  class c2;
    function void g(); $display("%p", this); endfunction
  endclass
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
