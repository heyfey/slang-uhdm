// r10uvm177 grid arm A — THE DISCRIMINATOR ARM.
// Declared-type KIND (direct enum typedef / alias-of-an-enum-typedef /
// alias-of-an-alias / anonymous enum written inline) x LISTING (in-body class
// method / out-of-body `extern` definition / package free function / module
// function).  Names deliberately do NOT sort or spell alike (RESUME §9: a grid
// that names everything a_t/b_t/c_t over A/B/C is self-confirming), and the
// alias is declared BOTH before and after the direct enum it aliases.
package zpk177;

  typedef enum { Q_ONE, Q_TWO } qbase_e;      // a DIRECT enum typedef
  typedef qbase_e QALIAS_T;                   // ALIAS of an enum typedef
  typedef QALIAS_T mid3;                      // ALIAS of an ALIAS
  typedef enum bit [2:0] { R_A, R_B, R_C } rdirect_e;  // direct, based
  typedef rdirect_e Alias2R;                  // ALIAS of a based enum typedef

  class Kls177;
    typedef enum { W_X, W_Y } wclass_e;       // class-scope direct enum td
    typedef wclass_e wcls_alias;              // class-scope ALIAS of it

    extern function QALIAS_T  x_oob_alias();
    extern function rdirect_e y_oob_direct();
    extern function mid3      z_oob_alias3();
    extern function Alias2R   p_oob_alias2();
    extern function wcls_alias q_oob_clsalias();
    extern function wclass_e  r_oob_clsdirect();

    function QALIAS_T   a_ib_alias();     return Q_ONE; endfunction
    function rdirect_e  b_ib_direct();    return R_A;   endfunction
    function mid3       c_ib_alias3();    return Q_TWO; endfunction
    function wcls_alias d_ib_clsalias();  return W_X;   endfunction
    function wclass_e   e_ib_clsdirect(); return W_Y;   endfunction
  endclass

  function QALIAS_T   Kls177::x_oob_alias();    return Q_TWO; endfunction
  function rdirect_e  Kls177::y_oob_direct();   return R_B;   endfunction
  function mid3       Kls177::z_oob_alias3();   return Q_ONE; endfunction
  function Alias2R    Kls177::p_oob_alias2();   return R_C;   endfunction
  function Kls177::wcls_alias Kls177::q_oob_clsalias(); return W_Y; endfunction
  function Kls177::wclass_e Kls177::r_oob_clsdirect(); return W_X; endfunction

  function QALIAS_T  free_alias();   return Q_ONE; endfunction
  function rdirect_e free_direct();  return R_C;   endfunction
  function mid3      free_alias3();  return Q_TWO; endfunction
endpackage

module tp177;
  import zpk177::*;
  function zpk177::QALIAS_T  m_alias();   return Q_ONE; endfunction
  function zpk177::rdirect_e m_direct();  return R_A;   endfunction
  function QALIAS_T          m_walias();  return Q_TWO; endfunction
  initial begin
    Kls177 k;
    k = new();
    $display(m_alias(), m_direct(), m_walias(), free_alias(), free_direct(),
             free_alias3(), k.a_ib_alias(), k.x_oob_alias());
  end
endmodule
