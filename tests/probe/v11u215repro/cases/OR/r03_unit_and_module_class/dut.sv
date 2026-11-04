// § opIdxRecvElemFollowsPath215 — a $unit class, a module-local class and a module function (operation and plain indexes; opIdxRecvPlainElab215 in the elaborated view)
class fld;
  function int get(); return 0; endfunction
endclass
class uc;
  fld fields[$];
  function int f(int i);
    return fields[i-1].get() + fields[i].get();
  endfunction
endclass
module m(input int k, output int o);
  class lc;
    fld fields[$];
    function int f(int i);
      return fields[i-1].get() + fields[i].get();
    endfunction
  endclass
  fld fs[$];
  function automatic int g(int i);
    return fs[i-1].get() + fs[i].get();
  endfunction
  always_comb o = fs[k-1].get();
endmodule
