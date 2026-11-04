// § foreachArrayNamesTypedef417
package p;
  typedef int b;
endpackage
import p::*;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
