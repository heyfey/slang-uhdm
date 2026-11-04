// § foreachArrayNamesClass417
class b;
  int v;
endclass
class A;
  class C;
    int n;
    function int f();
      int b[3];
      foreach (b[i]) n += i;
      return n;
    endfunction
  endclass
endclass
module top;
endmodule
