// § clsTpKwDefaultArrElemAtUse247
package p;
  class outer #(type T=int);
    class inner;
      T iq[$];
    endclass
    T oq[$];
    function void f(T v); endfunction
  endclass
endpackage
module top;
  import p::*;
  outer x;
endmodule
