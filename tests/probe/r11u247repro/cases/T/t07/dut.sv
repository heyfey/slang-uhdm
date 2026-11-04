// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=bit, type U=byte);
    T queue[$];
    U dyn[];
    function void put(T a, U b); endfunction
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
