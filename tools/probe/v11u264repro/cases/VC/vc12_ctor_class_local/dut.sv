// § ctorBidLhsCloneCopy264
package bp;
  class item;
    int v;
  endclass
  class c;
    int x;
    item last;
    extern function new(string name);
  endclass
  function c::new(string name);
    item it;
    bit ok;
    logic [3:0] nib;
    it = new;
    ok = 1;
    nib = 4'h3;
    last = it;
    x = nib;
  endfunction
endpackage
package up;
  import bp::*;
  class d extends c;
    function new(string name); super.new(name); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin
    d o = new("o");
  end
endmodule
