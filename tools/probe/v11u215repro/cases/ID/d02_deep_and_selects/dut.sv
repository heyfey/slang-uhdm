// § incDecOperandKeepsLvalueForm215 — two-level handle paths, an array element in the middle, an rvalue index, a return
package p;
  class leaf; int cnt; int arr[4]; endclass
  class mid; leaf lf; leaf lfs[2]; endclass
  class top_c;
    mid md;
    int buf_q[8];
    function void h(int x); endfunction
    function int run(int i);
      h(md.lf.cnt++);
      h(md.lfs[i].cnt++);
      h(buf_q[md.lf.cnt++]);
      md.lf.arr[md.lf.cnt--] = 2;
      return md.lf.cnt++;
    endfunction
  endclass
endpackage
module m;
endmodule
