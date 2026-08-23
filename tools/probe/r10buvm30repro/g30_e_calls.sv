package p30f;
  class c30f;
    int m;
    function int helper(int a); return a + m; endfunction
    extern function int u_call();
    extern function int u_meth();
    extern function string u_sform();
    extern function int u_sys();
    extern function int u_sysplain();
    extern function int u_mix();
    extern function int u_str();
  endclass
  function int c30f::u_call();    return helper(-1);                 endfunction // 14
  function int c30f::u_meth();    return this.helper(-1);            endfunction // 15
  function string c30f::u_sform();return $sformatf("%0d", -1);       endfunction // 16
  function int c30f::u_sys();     return $signed(-1);                endfunction // 17
  function int c30f::u_sysplain();return $unsigned(-1);              endfunction // 18
  function int c30f::u_mix();     return helper(-1) + (m == -2);     endfunction // 19
  function int c30f::u_str();     return (m == -1) ? -3 : -4;        endfunction // 20
endpackage
