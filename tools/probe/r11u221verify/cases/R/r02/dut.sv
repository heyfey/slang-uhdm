// § opIdxRecvElemFollowsPath215 + § opIdxRecvPlainElab215 — module-local class receivers with operation and plain indices, a module function inside a generate block, and a genvar index (v11u215 residue 5)
class fld;
  function int get(); return 0; endfunction
endclass
module m (input int k, output int o [2]);
  class lc;
    fld fields[$];
    function int f(int i);
      return fields[i-1].get() + fields[i].get();
    endfunction
  endclass
  fld fs[4];
  for (genvar g = 1; g < 3; g++) begin : gb
    function automatic int h(int i);
      return fs[i+g].get() + fs[g-1].get();
    endfunction
    always_comb o[g-1] = h(k);
  end
endmodule
