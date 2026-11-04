// § foreachArrayNamesClass417
class b;
  int v;
endclass
class C;
  int n;
  function int find(int m[$]);
    int b[$];
    b = m;
    foreach (b[idx]) n++;
    return n;
  endfunction
endclass
module top;
endmodule
