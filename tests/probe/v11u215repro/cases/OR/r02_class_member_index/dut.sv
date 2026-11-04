// § opIdxRecvElemFollowsPath215 — an index reading a class property, a this. property, a static and a local beside it
package p;
  class fld;
    function int get(); return 0; endfunction
  endclass
  class reg_c;
    fld fields[$];
    int k;
    static int sk;
    function int f(int i);
      int a;
      a = fields[k-1].get();
      a = fields[this.k-1].get();
      a = fields[sk+i].get();
      a = fields[i-k].get();
      return a;
    endfunction
  endclass
endpackage
module m;
endmodule
