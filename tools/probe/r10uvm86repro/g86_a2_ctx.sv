package pg2;
  parameter int PW = 5;
  localparam int LW = -3;
  typedef enum int { E0=0, E1=1 } e_t;
  int gvar;
  function int pf_neg(); return -1; endfunction
  function int pf_param(); return PW; endfunction
  function int pf_lparam(); return LW; endfunction
  function int pf_var(); return gvar; endfunction
  function int pf_call(); return pf_neg(); endfunction
  function int pf_add(); return PW + 1; endfunction
  function int pf_tern(); return (PW > 2) ? -1 : 2; endfunction
  function int pf_cmp(); return 1 == 2; endfunction
  function int pf_concat(); return {2'b01, 2'b10}; endfunction
  function string pf_str(); return "ab"; endfunction
  function real pf_real(); return -1.5; endfunction
  function int pf_bits(); return $bits(int); endfunction
  function int pf_enum(); return E1; endfunction
  function int pf_arg(int a); return -a; endfunction
  function int pf_argl(int a); return a + -1; endfunction
  function int pf_neg1s(); return -1'sb1; endfunction
  function int pf_negbig(); return -32'd5; endfunction
  class kk;
    int q;
    extern function int m_ret();
    function int m_in(); return -1; endfunction
  endclass
  function int kk::m_ret(); return -1; endfunction
endpackage
module mtop2;
  function int mf_neg(); return -1; endfunction
endmodule
