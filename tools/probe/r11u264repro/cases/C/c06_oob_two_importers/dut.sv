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
package p2;
  import p1::*;
  class d2 extends base;
    function new(); super.new("a"); endfunction
  endclass
endpackage
package p3;
  import p1::*;
  class d3 extends base;
    function new(); super.new("b"); endfunction
  endclass
endpackage
module top;
  import p2::*;
  import p3::*;
  d2 x; d3 y;
  initial begin x = new; y = new; end
endmodule
