// § ctorBidLhsCloneCopy264
package p1;
  class base;
    extern function new(string name);
  endclass
  function base::new(string name);
    string s;
    int k = 3;
    int a[2];
    bit [3:0] b4;
    base h = null;
    k = a[0] + b4;
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
