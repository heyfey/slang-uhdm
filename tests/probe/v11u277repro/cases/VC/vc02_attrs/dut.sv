// § ctorRetVarSiblingSpan277
package p;
  class e1;
    function new((* a *) (* b *) int x);
    endfunction
  endclass
  class e2;
    function new((* a, b = 1 *) input string s);
    endfunction
  endclass
  class e3;
    function new((* a *) [3:0] x);
    endfunction
  endclass
  class e4;
    function new((* a *) input [3:0] x);
    endfunction
  endclass
  class e5;
    function new((* a *) x);
    endfunction
  endclass
endpackage
module top;
  p::e1 x;
endmodule
