// § foreachArrayNamesClass417
package p;
  class b;
    int v;
  endclass
endpackage
package q;
  import p::*;
  function automatic int g();
    int b[2];
    int n;
    foreach (b[i]) n += i;
    return n;
  endfunction
endpackage
module top;
  int n;
  initial n = q::g();
endmodule
