// § clsSpecArgTsFileAtArg434
package p;
  class res2 #(type T = int, type U = int);
    T v;
    U w;
  endclass
  `include "spec.svh"
endpackage
import p::*;
class C;
  res2#(string, byte) pr;
  function void f();
    res2#(string, byte) t;
  endfunction
endclass
module top;
endmodule
