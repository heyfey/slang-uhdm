// § foreachArrayNamesClass417
class b #(int W = 2);
  int v;
endclass
class A;
  int n;
  function int f();
    int b[3];
    foreach (b[i]) n += i;
    return n;
  endfunction
endclass
module top;
endmodule
