// § ctorRetVarSiblingSpan277
package p;
  class o1;
    extern function new(input string s);
  endclass
  function o1::new(string s);
  endfunction
  class o2;
    extern function new(string s);
  endclass
  function o2::new(input string s);
  endfunction
  class o3;
    extern function new(input int a = 3);
  endclass
  function o3::new(input int a);
  endfunction
endpackage
module top;
  p::o1 x;
endmodule
