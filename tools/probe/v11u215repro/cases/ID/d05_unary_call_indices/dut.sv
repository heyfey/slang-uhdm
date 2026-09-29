// § incDecOperandKeepsLvalueForm215 — inc/dec operands behind unary and call indices, in a method argument and a return
package p;
  class leaf; int cnt; endclass
  class mid; leaf lfs[4]; endclass
  class top_c;
    mid md;
    function int g(int x); return x; endfunction
    function void h(int x); endfunction
    function int run(int i);
      h(md.lfs[g(i)].cnt++);
      h(md.lfs[-i].cnt--);
      h(g(md.lfs[i+1].cnt++));
      return ++md.lfs[g(i-1)].cnt;
    endfunction
  endclass
endpackage
module m;
endmodule
