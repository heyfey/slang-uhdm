// § castTypeParamDefaultLoc292
package p;
  typedef int myint_t;
  class gen #(type T = int unsigned, type U = byte unsigned, type V = bit, type W = myint_t, type X = integer unsigned);
    longint y;
    function void x2();
      y = T'(3);
      y = U'(3);
      y = V'(1);
      y = W'(3);
      y = X'(3);
      y = T'(y) + U'(y);
    endfunction
  endclass
endpackage
module top; endmodule
