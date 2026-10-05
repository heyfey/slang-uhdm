// § clsTpKwDefaultArrElemAtUse247
package p;
  typedef int my_t;
  class q #(type T=my_t);
    T a[$];
    T b[3];
    function void put(T x); endfunction
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
