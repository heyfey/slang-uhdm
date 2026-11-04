// § ctorRetVarSiblingSpan277
package p;
  class cr1;
    function new(input
      int
        a, input string b);
    endfunction
  endclass
  class cr2;
    function new((* k *) input [2:0] a);
    endfunction
  endclass
endpackage
module top;
  p::cr1 x;
endmodule
