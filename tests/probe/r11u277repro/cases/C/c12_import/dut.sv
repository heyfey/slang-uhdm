// § ctorRetVarSiblingSpan277
package p;
  class o1;
    extern function new(input string s, int k = 0);
  endclass
  function o1::new(input string s, int k = 0);
  endfunction
  class o2;
    function new(ref int r);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  o1 x;
  initial x = new("a");
endmodule
module top2;
  import p::o1;
  o1 y;
endmodule
