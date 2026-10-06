// § ctorBidLhsCloneCopy264
package p1;
  class base;
    int m;
    extern function new(string name);
  endclass
  function base::new(string name);
    string error_str;
    int k;
    begin
      int inner;
      inner = k;
    end
    error_str = name;
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
