// § clsAssocVecIdxTs450
package p;
  class C;
    int a[bit[7:0]] = '{default:0};
    bit [7:0] m[bit[7:0]];
  endclass
endpackage
module top;
  import p::*;
  C c = new;
  initial c.m[3] = 1;
endmodule
