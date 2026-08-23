package p30g;
  function int pkgf(int a); return a; endfunction
  class c30g;
    int m;
    function int meth(int a); return a + m; endfunction
    extern function int k_pkgcall();
    extern function int k_selfcall();
    extern function int k_thiscall();
    extern function int k_objcall();
    extern function int k_clog2();
    extern function int k_bits();
    extern function int k_sform();
    extern function int k_disp();
    extern function int k_cast();
    extern function int k_min();
  endclass
  function int c30g::k_pkgcall();  return pkgf(-1);                 endfunction // 18
  function int c30g::k_selfcall(); return meth(-1);                 endfunction // 19
  function int c30g::k_thiscall(); return this.meth(-1);            endfunction // 20
  function int c30g::k_objcall();  return $clog2(-1);               endfunction // 21
  function int c30g::k_clog2();    return $bits(-1);                endfunction // 22
  function int c30g::k_bits();     return $sformatf("%0d",-1).len(); endfunction // 23
  function int c30g::k_sform();    return $countones(-1);           endfunction // 24
  function int c30g::k_disp();     return int'(-1);                 endfunction // 25
  function int c30g::k_cast();     return m inside {-1, 2};         endfunction // 26
  function int c30g::k_min();      return {2{-1}};                  endfunction // 27
endpackage
