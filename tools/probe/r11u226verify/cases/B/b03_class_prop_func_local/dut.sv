// § fixedOuterAssocInnerReg223 — a leading-fixed associative array as a class property, as an automatic function local and as a module variable with a queue after the associative
package p;
  class c;
    int cp [2][string];
    function int f();
      int fl [3][int];
      return fl[0].num();
    endfunction
  endclass
endpackage
module top;
  import p::*;
  int mq [2][int][$];
endmodule
