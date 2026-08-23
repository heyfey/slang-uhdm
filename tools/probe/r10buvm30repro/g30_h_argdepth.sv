package p30i;
  int gv;
  class c30i;
    int m;
    function int meth(int a); return a + m; endfunction
    extern function int d_nested();
    extern function int d_two();
    extern function int d_meth2();
  endclass
  function int c30i::d_nested(); return meth(1 + -1);        endfunction // 10
  function int c30i::d_two();    return meth(-1) + m;        endfunction // 11
  function int c30i::d_meth2();  return this.meth(1 + -1);   endfunction // 12
endpackage
