// § incDecOperandKeepsLvalueForm215 — handle-member inc/dec in a for step, a system call argument, a nested call argument and an if condition
package p;
  class seq; int n; int m; endclass
  class sqr;
    seq sp;
    function int g(int x); return x; endfunction
    function void h(int x); endfunction
    function void run();
      for (int i = 0; i < 4; sp.n++) h(i);
      $display("%0d", sp.m++);
      h(g(sp.n--));
      if (++sp.m > 3) h(0);
      h(g(g(++sp.n)));
    endfunction
  endclass
endpackage
module m;
endmodule
