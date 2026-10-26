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
`define RD(TYPE) res#(TYPE) t;
class C;
  res#(logic signed [7:0]) pr;
  function void f();
    `RD(logic signed [7:0])
  endfunction
endclass
module top;
endmodule
