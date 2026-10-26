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
module top;
  class C;
    res#(bit [3:0]) pr;
    function void f();
      res#(bit [3:0]) t;
    endfunction
  endclass
endmodule
