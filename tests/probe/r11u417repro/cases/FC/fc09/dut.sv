// § foreachArrayNamesClass417
package q;
  class b;
    int v;
  endclass
endpackage
module top;
  import q::*;
  int b[3];
  int n;
  initial foreach (b[i]) n += i;
endmodule
