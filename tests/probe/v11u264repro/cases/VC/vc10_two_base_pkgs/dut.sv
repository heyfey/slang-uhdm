// § ctorBidLhsCloneCopy264
package b1;
  class c1;
    int x;
    extern function new(string name);
  endclass
  function c1::new(string name);
    string s;
    int a;
    s = name;
    a = 1;
    x = a;
  endfunction
endpackage
package b2;
  class c2;
    int y;
    extern function new(int k);
  endclass
  function c2::new(int k);
    int t;
    t = k;
    y = t;
  endfunction
endpackage
package user_pkg;
  import b1::*;
  import b2::*;
  class u1 extends c1;
    function new(string name); super.new(name); endfunction
  endclass
  class u2 extends c2;
    function new(); super.new(2); endfunction
  endclass
endpackage
module top;
  import user_pkg::*;
  initial begin
    u1 a = new("a");
    u2 b = new();
  end
endmodule
