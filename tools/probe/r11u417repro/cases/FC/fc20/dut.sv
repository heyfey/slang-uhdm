// § foreachArrayNamesClass417
package p;
  class b;
    int w;
  endclass
  function automatic int f(int m[$]);
    int b[$];
    int n;
    b = m;
    foreach (b[idx]) n += idx;
    return n;
  endfunction
endpackage
class b;
  int v;
endclass
module top;
endmodule
