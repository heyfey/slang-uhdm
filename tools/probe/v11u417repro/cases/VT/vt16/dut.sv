// § foreachArrayNamesTypedef417
package p;
  typedef enum logic [1:0] {X, Y} b;
endpackage
module top;
  import p::*;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
