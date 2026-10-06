// § ctorBidLhsCloneCopy264
package p0;
  class root;
    function new(string n); endfunction
  endclass
endpackage
package p1;
  import p0::*;
  class base extends root;
    extern function new(string name);
  endclass
  function base::new(string name);
    string error_str;
    int k;
    super.new(name);
    k = 4;
    begin
      int inner;
      inner = k;
    end
  endfunction
endpackage
package p2;
  import p1::*;
  class derived extends base;
    function new(); super.new("a"); endfunction
  endclass
endpackage
module top;
  import p2::*;
  derived d;
  initial d = new;
endmodule
