// § clsAssocVecIdxTs450
package p;
  class C;
    bit[7:0] mem[bit[7:0]];
  endclass
endpackage
package q;
  import p::*;
  class D;
    bit[7:0] mem[bit[7:0]];
    logic[3:0] m2[logic[3:0]];
  endclass
endpackage
module top;
  import q::*;
endmodule
