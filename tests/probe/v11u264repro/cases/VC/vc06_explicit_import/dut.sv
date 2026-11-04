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
package up;
  import bp::c;
  class d extends c;
    function new(); super.new(); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin d o = new(); end
endmodule
