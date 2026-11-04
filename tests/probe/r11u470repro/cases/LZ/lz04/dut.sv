// § clsPropSpecFullNameLazy470 (the property's specialization also used by a method local)
package p;
  class res #(type T = int);
    T v;
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
