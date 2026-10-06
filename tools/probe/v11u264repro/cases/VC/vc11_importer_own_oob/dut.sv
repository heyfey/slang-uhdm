// § ctorBidLhsCloneCopy264
package bp;
  class c;
    int x;
    extern function new(string name);
  endclass
  function c::new(string name);
    string s;
    int a;
    s = name;
    a = 2;
    x = a;
  endfunction
endpackage
package up;
  import bp::*;
  class d extends c;
    int z;
    extern function new(string name);
  endclass
  function d::new(string name);
    string q;
    int w;
    super.new(name);
    q = name;
    w = 3;
    z = w;
  endfunction
endpackage
module top;
  import up::*;
  initial begin
    d o = new("o");
  end
endmodule
