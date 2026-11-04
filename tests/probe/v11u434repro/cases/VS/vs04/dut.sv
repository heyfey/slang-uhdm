// § clsSpecArgTsFileAtArg434
package p;
  class res #(type T = int);
    T v;
  endclass
  class res2 #(type T = int, type U = int);
    T v; U w;
  endclass
  `include "spec.svh"
endpackage
import p::*;
class C;
  res#(int unsigned) pr;
  function void f();
    res#(int unsigned) t;
  endfunction
endclass
module top;
endmodule
