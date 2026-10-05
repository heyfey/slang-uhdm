// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=int, type U=T);
    U queue[$];
    T aa[int];
    function void put(U b); endfunction
    task tk(output T o); endtask
  endclass
endpackage
module top;
  import p::*;
  q#(shortint) x;
endmodule
