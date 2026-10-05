// § hpFnStaticTrailScopeJoin246
package p;
  import "DPI-C" function void ext_free(chandle h);
  function void g(int v); endfunction
  class d; int x; static int sx; endclass
  class c;
    d hd;
    virtual function void visit(int node);
      static chandle compiled_regex;
      static int cnt;
      if (compiled_regex == null) cnt = cnt + 1;
    endfunction
    virtual function void end_v();
      d l;
      ext_free(visit.compiled_regex);
      g(visit.cnt);
      g(l.x);
      g(hd.x);
      g(d::sx);
    endfunction
  endclass
endpackage
module top;
  function int mf(); static int sv; return 0; endfunction
  function void usev(int v); endfunction
  initial usev(mf.sv);
endmodule
