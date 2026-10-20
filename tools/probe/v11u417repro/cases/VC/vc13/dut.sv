// § foreachArrayNamesClass417
class b;
  int v;
endclass
module top;
  int n;
  function int f(int b[3]);
    foreach (b[i]) n += b[i];
    return n;
  endfunction
  initial n = f('{1, 2, 3});
endmodule
