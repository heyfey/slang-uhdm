// § clsSpecArgTsFileAtArg434
package p;
  class res #(type T = int);
    T v;
  endclass
  class ir extends res #(int);
  endclass
endpackage
import p::*;
class C;
  res#(int) pr;
  function void f();
    res#(int) t;
  endfunction
endclass
module top;
endmodule
