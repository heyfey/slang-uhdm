// § ctorBidLhsCloneCopy264
package p1;
  class base;
    int q;
    extern function new(string name, base parent);
  endclass
  function base::new(string name, base parent);
    string error_str;
    base top;
    int k;
    k = 1;
    if (parent == null) error_str = name;
  endfunction
endpackage
package p2;
  import p1::*;
  class derived extends base;
    function new(string name);
      super.new(name, null);
    endfunction
  endclass
endpackage
module top;
  import p2::*;
  derived d;
  initial d = new("x");
endmodule
