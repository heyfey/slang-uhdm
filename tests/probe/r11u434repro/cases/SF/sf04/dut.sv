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
  `RP(int)
  function void f();
    `RD(int)
  endfunction
endclass
module top;
endmodule
