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
  res#(bit [1:0]) pr;
  function void f();
    res#(bit [1:0]) t;
    res#(bit [0:1]) u;
  endfunction
endclass
module top;
endmodule
