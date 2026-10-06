// § ctorBidLhsCloneCopy264
package bp;
  function automatic int twice(int a, int b = 1); return a * 2 + b; endfunction
  virtual class vb;
    pure virtual function int get();
  endclass
  class c extends vb;
    int r;
    extern function new(int k);
    extern virtual function int get();
  endclass
  function c::new(int k);
    int t = twice(.a(k), .b(2));
    int u;
    string s;
    u = twice(.a(t));
    s = "z";
    r = u;
  endfunction
  function int c::get(); return r; endfunction
endpackage
package up;
  import bp::*;
  class d extends c;
    function new(); super.new(1); endfunction
  endclass
endpackage
module top;
  import up::*;
  initial begin d o = new(); end
endmodule
