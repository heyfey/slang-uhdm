// § incDecOperandKeepsLvalueForm215 — right sides, conditions and returns
package p;
  class seq; int n; endclass
  class sqr;
    seq sp;
    function int f();
      int y;
      y = sp.n++;
      y = ++sp.n;
      if (sp.n-- > 0) y = 1;
      while (sp.n-- > 0) y++;
      return ++sp.n;
    endfunction
  endclass
endpackage
module m;
endmodule
