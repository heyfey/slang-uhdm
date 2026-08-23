package p30d;
  class c30d;
    int m;
    int arr[];
    extern function int r_paren();
    extern function int r_cmp();
    extern function int r_cmp_nopar();
    extern function int r_deep();
    extern function int r_concat();
    extern function int r_tern();
    extern function int r_call();
    extern function int r_index();
    extern function int r_add();
    extern function int r_tilde();
    extern function int r_uplus();
    extern function int r_notlit();
    extern function int r_dblneg();
    extern function real r_real();
    extern function int r_based();
    extern function int r_sized();
    extern function int r_wide();
    extern function int r_space();
    extern function int r_parenlit();
  endclass

  function int c30d::r_paren();      return (-1);            endfunction // 26
  function int c30d::r_cmp();        return (m == -1);       endfunction // 27
  function int c30d::r_cmp_nopar();  return m == -1;         endfunction // 28
  function int c30d::r_deep();       return ((m + (-1)) * 2);endfunction // 29
  function int c30d::r_concat();     return {-1, 1};         endfunction // 30
  function int c30d::r_tern();       return m ? -1 : 1;      endfunction // 31
  function int c30d::r_call();       return $signed(-1);     endfunction // 32
  function int c30d::r_index();      return arr[-1];         endfunction // 33
  function int c30d::r_add();        return 1 + 2;           endfunction // 34
  function int c30d::r_tilde();      return ~1;              endfunction // 35
  function int c30d::r_uplus();      return +1;              endfunction // 36
  function int c30d::r_notlit();     return -m;              endfunction // 37
  function int c30d::r_dblneg();     return -(-1);           endfunction // 38
  function real c30d::r_real();      return -1.5;            endfunction // 39
  function int c30d::r_based();      return (m == -'d1);     endfunction // 40
  function int c30d::r_sized();      return (m == -8'd3);    endfunction // 41
  function int c30d::r_wide();       return (m == -32'hFFFFFFFF); endfunction // 42
  function int c30d::r_space();      return (m == - 1);      endfunction // 43
  function int c30d::r_parenlit();   return (m == -(1));     endfunction // 44
endpackage
