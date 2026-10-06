// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int r;
    extern function new(string name);
  endclass
  function c::new(string name);
    string s;
    int a;
    s = name;
    a = 1;
    r = a;
  endfunction
endpackage
package u1;
  import bp::*;
  class d1 extends c;
    function new(); super.new("d1"); endfunction
  endclass
endpackage
package u2;
  import bp::*;
  class d2 extends c;
    function new(); super.new("d2"); endfunction
  endclass
endpackage
module top;
  import u1::*;
  import u2::*;
  initial begin
    d1 a = new();
    d2 b = new();
  end
endmodule
