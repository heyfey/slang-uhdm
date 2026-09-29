// § opIdxRecvElemFollowsPath215 — unary, ternary, concatenation, multi-dim and middle-segment operation indexes of deep receivers
package p;
  class fld;
    function int get(); return 0; endfunction
    fld sub;
  endclass
  class grp; fld fs[4]; endclass
  class reg_c;
    fld fields[$];
    fld grid[4][4];
    grp gs[4];
    function int f(int i, int j, bit c);
      int a;
      a = fields[-i].get();
      a = fields[c ? i : j].get();
      a = grid[i-1][j+1].get();
      a = gs[i-1].fs[j].get();
      a = fields[i-1].sub.get();
      a = fields[i+j*2-1].get();
      fields[i-1].get();
      return a;
    endfunction
  endclass
endpackage
module m;
endmodule
