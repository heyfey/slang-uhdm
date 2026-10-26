// § clsSpecArgTsFileAtArg434
package p;
  parameter int N = 4;
  class res #(type T = int);
    T v;
  endclass
  `include "spec.svh"
endpackage
import p::*;
class C;
  res#(logic [p::N-1:0]) pr;
  function void f();
    res#(logic [p::N-1:0]) t;
  endfunction
endclass
module top;
endmodule
