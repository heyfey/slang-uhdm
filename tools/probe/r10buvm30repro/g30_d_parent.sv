package p30e;
  class c30e;
    int m;
    int arr[];
    extern function int t_signedbase();
    extern function int t_syscall();
    extern function int t_concat();
    extern function int t_tern();
    extern function int t_index();
    extern function int t_cmp();
    extern function int t_plainlit_syscall();
    extern function int t_plainlit_concat();
    extern function int t_plainlit_tern();
    extern function int t_plainlit_index();
    extern function int t_plainlit_cmp();
    extern function int t_nested2();
    extern function int t_negofneg();
  endclass
  function int c30e::t_signedbase();      return (m == -4'sd8);   endfunction // 20
  function int c30e::t_syscall();         return $signed(-1);     endfunction // 21
  function int c30e::t_concat();          return {-1, 1};         endfunction // 22
  function int c30e::t_tern();            return m ? -1 : 1;      endfunction // 23
  function int c30e::t_index();           return arr[-1];         endfunction // 24
  function int c30e::t_cmp();             return (m == -1);       endfunction // 25
  function int c30e::t_plainlit_syscall();return $signed(1);      endfunction // 26
  function int c30e::t_plainlit_concat(); return {1, 1};          endfunction // 27
  function int c30e::t_plainlit_tern();   return m ? 1 : 1;       endfunction // 28
  function int c30e::t_plainlit_index();  return arr[1];          endfunction // 29
  function int c30e::t_plainlit_cmp();    return (m == 1);        endfunction // 30
  function int c30e::t_nested2();         return ((m + (-1)) == (m * -2)); endfunction // 31
  function int c30e::t_negofneg();        return (m == -(-1));    endfunction // 32
endpackage
