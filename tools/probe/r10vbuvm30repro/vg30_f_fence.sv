package pv30f;
  int gv;
  function int helper(int a); return a + gv; endfunction
  class cv30f;
    int m;
    function int meth(int a); return a + m; endfunction
    extern function int f_concat_in_call();
    extern function int f_call_in_concat();
    extern function int f_negofneg_concat();
    extern function int f_negofneg_idx();
    extern function int f_call_deep2();
    extern function int f_meth_of_call();
    extern function int f_call_of_meth();
  endclass
  function int cv30f::f_concat_in_call(); return helper({-1, 1});          endfunction
  function int cv30f::f_call_in_concat(); return {helper(1), -2};          endfunction
  function int cv30f::f_negofneg_concat();return {-(-1), 1};               endfunction
  function int cv30f::f_negofneg_idx();   return (m == -(-(1)));           endfunction
  function int cv30f::f_call_deep2();     return helper(helper(1 + -1));   endfunction
  function int cv30f::f_meth_of_call();   return this.meth(helper(-1));    endfunction
  function int cv30f::f_call_of_meth();   return helper(this.meth(-1));    endfunction
endpackage
