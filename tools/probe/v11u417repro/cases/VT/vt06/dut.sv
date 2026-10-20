// § foreachArrayNamesTypedef417
package p;
  typedef bit [3:0] b;
endpackage
module top;
  import p::*;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
