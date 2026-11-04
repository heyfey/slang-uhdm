// § foreachArrayNamesClass417
module top;
  class b;
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
endmodule
