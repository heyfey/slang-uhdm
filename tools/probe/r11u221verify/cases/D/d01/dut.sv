// § incDecOperandKeepsLvalueForm215 — member inc/dec in system-task arguments, array indices on both sides, an if and a while condition, a return and a for step
package p;
  class st; int a; int i; int j; int c; endclass
  class drv;
    st s;
    int arr[8];
    function int f();
      $display("%0d", s.a++);
      arr[s.i++] = arr[s.j--];
      if (s.c-- > 0) s.a = 1;
      while (s.c++ < 3) s.a = 2;
      for (int k = 0; k < 2; s.i++) k++;
      return s.a--;
    endfunction
  endclass
endpackage
module m;
endmodule
