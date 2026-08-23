package p30h;
  int pkgvar;
  function int hardf(int a); hardf = a + pkgvar; endfunction
  function automatic int autof(int a); return a; endfunction
  class c30h;
    int m;
    static int sm;
    function int meth(int a); return a + m; endfunction
    static function int smeth(int a); return a + sm; endfunction
    extern function int n_hard();
    extern function int n_auto();
    extern function int n_meth();
    extern function int n_smeth();
    extern function int n_scope();
  endclass
  function int c30h::n_hard();   return hardf(-1);        endfunction // 17
  function int c30h::n_auto();   return autof(-1);        endfunction // 18
  function int c30h::n_meth();   return meth(-1);         endfunction // 19
  function int c30h::n_smeth();  return smeth(-1);        endfunction // 20
  function int c30h::n_scope();  return c30h::smeth(-1);  endfunction // 21
endpackage
