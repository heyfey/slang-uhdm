// § clsLocalTypeParamArgBare428v
package p;
  class box #(type T = int);
  endclass
endpackage
import p::*;
class B #(type U = int);
  function void f();
    box #(U) b;
  endfunction
endclass
class D;
  B #(shortint) h;
endclass
module top;
  D d;
endmodule
