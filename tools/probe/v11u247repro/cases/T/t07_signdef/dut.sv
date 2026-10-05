// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=bit signed [3:0], type U=byte unsigned, type V=integer);
    T a[$];
    U b[2];
    V c[];
    function void put(T x, U y, V z); endfunction
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
