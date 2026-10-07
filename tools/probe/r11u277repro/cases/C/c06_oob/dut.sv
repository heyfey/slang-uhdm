// § ctorRetVarSiblingSpan277
package p;
  class o1;
    extern function new(input string s);
  endclass
  function o1::new(input string s);
  endfunction
  class o2;
    extern function new(int a);
  endclass
  function o2::new(int a);
  endfunction
endpackage
module top;
  p::o1 x;
endmodule
