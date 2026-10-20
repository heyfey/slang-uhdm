// § foreachArrayNamesClass417
package p;
  class b;
    int v;
  endclass
endpackage
import p::*;
module top;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
