// § ctorBidLhsCloneCopy264
package base_pkg;
  class item;
    int v;
    function new(); v = 0; endfunction
  endclass
  class comp;
    int x;
    string nm;
    extern function new(string name, int k);
  endclass
  function comp::new(string name, int k);
    string s;
    int a, b;
    item it;
    this.nm = name;
    a = k;
    b = a + 1;
    s = name;
    it = new();
    this.x = b;
  endfunction
endpackage
package user_pkg;
  import base_pkg::*;
  class user extends comp;
    function new(string name); super.new(name, 3); endfunction
  endclass
endpackage
module top;
  import user_pkg::*;
  initial begin
    user u = new("u");
  end
endmodule
