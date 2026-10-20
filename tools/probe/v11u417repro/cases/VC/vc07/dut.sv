// § foreachNestedClassAbstain417v
package p;
  class A;
    class b;
      int v;
    endclass
    int n;
    function int f();
      int b[3];
      foreach (b[i]) n += i;
      return n;
    endfunction
  endclass
endpackage
module top;
endmodule
