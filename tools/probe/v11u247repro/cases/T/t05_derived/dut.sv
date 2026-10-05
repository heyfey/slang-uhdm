// § clsTpKwDefaultArrElemAtUse247
package p;
  class b #(type T=int);
    T a[$];
    function void put(T x); endfunction
  endclass
  class d #(type T=int) extends b #(T);
    T z[];
    function void put2(T x); endfunction
  endclass
endpackage
module top;
  import p::*;
  d x;
  d#(byte) y;
endmodule
