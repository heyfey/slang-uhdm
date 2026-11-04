// § clsTpKwDefaultArrElemAtUse247
package p;
  class q #(type T=int);
    T queue[$];
    T fixed[3];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
