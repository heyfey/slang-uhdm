// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=logic [3:0], type U=string);
    T a[$];
    U b[$];
    function void put(T x, U y); endfunction
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
