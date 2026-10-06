// § ctorBidLhsCloneCopy264
package p1;
  class base;
    extern function new(string name);
  endclass
  function base::new(string name);
    string s;
    int k;
    k = 2;
  endfunction
endpackage
module top;
  import p1::*;
  base d;
  initial d = new("z");
endmodule
