// § ctorBidLhsCloneCopy264
package bp;
  class c1;
    int r;
    extern function new();
  endclass
  class c2;
    int r;
    extern function new();
    extern function void f();
  endclass
  function c1::new();
    int a;
    a = 1;
    r = a;
  endfunction
  function c2::new();
    int b;
    string t;
    b = 2;
    t = "q";
    r = b;
  endfunction
  function void c2::f();
    int z;
    z = r;
  endfunction
endpackage
package up;
  import bp::*;
  class d extends c2;
    function new(); super.new(); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin d o = new(); end
endmodule
