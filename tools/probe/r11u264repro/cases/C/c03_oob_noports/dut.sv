// § ctorBidLhsCloneCopy264
package p1;
  class base;
    extern function new();
  endclass
  function base::new();
    int a;
    string s;
    int k;
    k = a;
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
  initial d = new;
endmodule
