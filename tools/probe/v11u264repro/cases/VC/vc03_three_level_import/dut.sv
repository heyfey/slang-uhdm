// § ctorBidLhsCloneCopy264
package p1;
  class a;
    int z;
    extern function new();
  endclass
  function a::new();
    int t;
    bit f;
    t = 5;
    f = 1;
    z = t;
  endfunction
endpackage
package p2;
  import p1::*;
  class b extends a;
    function new(); super.new(); endfunction
  endclass
endpackage
package p3;
  import p2::*;
  import p1::*;
  class cc extends b;
    function new(); super.new(); endfunction
  endclass
endpackage
module top;
  import p3::*;
  initial begin cc o = new(); end
endmodule
