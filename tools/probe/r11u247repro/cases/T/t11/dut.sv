// § clsTpKwDefaultArrElemAtUse247
package p;
  typedef int my_t;
  class q #(type T=int);
    my_t tq[$];
    int iq[$];
    T a[$];
    extern function void put(T v);
  endclass
  function void q::put(T v); endfunction
endpackage
module top;
  import p::*;
  q x;
endmodule
