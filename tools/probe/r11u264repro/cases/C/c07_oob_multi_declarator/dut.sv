// § ctorBidLhsCloneCopy264
package p1;
  class base;
    extern function new(string name);
  endclass
  function base::new(string name);
    int a, b;
    string s1, s2 = "v";
    a = b;
  endfunction
endpackage
package p2;
  import p1::*;
  class derived extends base;
    function new(); super.new("a"); endfunction
  endclass
endpackage
module top;
  import p2::*;
  derived d;
  initial d = new;
endmodule
