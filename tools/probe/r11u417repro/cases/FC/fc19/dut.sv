// § foreachArrayNamesClass417
package q;
  class b;
    int v;
  endclass
endpackage
package r;
  import q::*;
  function automatic int f(int m[$]);
    int b[$];
    int n;
    b = m;
    foreach (b[idx]) n += idx;
    return n;
  endfunction
endpackage
module top;
endmodule
