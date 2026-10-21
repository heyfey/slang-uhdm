// § clsLocalTypeParamArgBare428v
package p;
  class box #(type T = int);
  endclass
endpackage
package zq;
  import p::*;
  class B #(type U = int);
    function void f();
      box #(int) b;
      box #(U) e;
    endfunction
  endclass
endpackage
module top;
  zq::B #(byte) c;
endmodule
