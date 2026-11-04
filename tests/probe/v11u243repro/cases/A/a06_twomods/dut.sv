// § thisNetSurelogAnchor243
// two modules importing two packages in opposite orders
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
