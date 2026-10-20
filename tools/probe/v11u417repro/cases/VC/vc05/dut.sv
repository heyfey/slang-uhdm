// § foreachArrayNamesClass417
module top;
  class b;
    int v;
  endclass
  int n;
  function int f();
    int b[4];
    foreach (b[i]) n += i;
    return n;
  endfunction
  initial n = f();
endmodule
