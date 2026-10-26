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
  res#(real) pr;
  res#(string) ps;
  function void f();
    res#(real) t;
  endfunction
endclass
module top;
endmodule
