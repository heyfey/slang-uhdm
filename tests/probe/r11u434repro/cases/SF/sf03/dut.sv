// § clsSpecArgTsFileAtArg434
package p;
  class res #(type T = int);
    T v;
  endclass
  `include "spec.svh"
endpackage
`include "defs.svh"
import p::*;
class C;
  function void f();
    res#(int) t;
  endfunction
endclass
module top;
endmodule
