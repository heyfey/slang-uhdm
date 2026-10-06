// § ctorBidLhsCloneCopy264
package p1;
  class base;
    extern function void f(string name);
    function new(); endfunction
  endclass
  function void base::f(string name);
    string s;
    int k;
    k = 2;
  endfunction
endpackage
package p2;
  import p1::*;
  class derived extends base;
  endclass
endpackage
module top;
  import p2::*;
  derived d;
  initial begin d = new; d.f("q"); end
endmodule
