// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=bit, type U=int unsigned);
    T a[$];
    U b[];
    T c[4];
    U d[string];
    function void put(T x, U y); a.push_back(x); endfunction
  endclass
endpackage
module top;
  import p::*;
  q x;
  q#(logic, byte) y;
endmodule
