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
localparam int N = 4;
class C;
  res#(logic [N-1:0]) pr;
  function void f();
    res#(logic [N-1:0]) t;
  endfunction
endclass
module top;
endmodule
