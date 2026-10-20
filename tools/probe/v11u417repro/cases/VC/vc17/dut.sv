// § foreachArrayNamesClass417
package q;
  class b;
    int v;
  endclass
endpackage
package p;
  import q::*;
  int x;
endpackage
module top;
  import p::*;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
