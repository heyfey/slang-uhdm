// § hpFnStaticTrailScopeJoin246
package p;
  import "DPI-C" function void ext_free(chandle h);
  class c;
    virtual function void visit(int node);
      static chandle compiled_regex;
      if (compiled_regex == null) compiled_regex = null;
    endfunction
    virtual function void end_v();
      ext_free(visit.compiled_regex);
      visit.compiled_regex = null;
    endfunction
  endclass
endpackage
module top;
endmodule
