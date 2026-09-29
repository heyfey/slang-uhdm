// § opIdxRecvPlainElab215 + § opIdxRecvElemFollowsPath215 — plain and operation indices in a package class method (both views), an interface-scope class, and a static class method
package p;
  class fld; function int get(); return 0; endfunction endclass
  class reg_c;
    fld fields[8];
    static fld sf[4];
    function int f(int k, int m);
      return fields[k].get() + fields[m].get() + fields[k+m].get() + sf[k].get();
    endfunction
    static function int g(int i); return sf[i-1].get() + sf[i].get(); endfunction
  endclass
endpackage
interface ifc;
  class ic;
    p::fld fs[4];
    function int h(int j); return fs[j].get() + fs[j*2].get(); endfunction
  endclass
endinterface
module m;
  ifc u();
endmodule
