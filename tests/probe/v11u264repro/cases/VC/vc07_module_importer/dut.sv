// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int r;
    extern function new();
  endclass
  function c::new();
    int a;
    string s;
    a = 3;
    s = "x";
    r = a;
  endfunction
endpackage
module top;
  import bp::*;
  initial begin c o = new(); end
endmodule
