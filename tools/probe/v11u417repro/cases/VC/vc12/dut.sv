// § foreachArrayNamesClass417
package p;
  class b;
    int v;
  endclass
endpackage
module top;
  import p::b;
  int b2[3];
  int n;
  function int f();
    int b[3];
    foreach (b[i]) n += i;
    return n;
  endfunction
  initial n = f();
endmodule
