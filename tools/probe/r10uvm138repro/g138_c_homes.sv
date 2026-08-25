// r10uvm138 arm C — HOME/VIEW grid.  The corpus head is an OUT-OF-BODY class
// method written at package scope (uvm_reg_block::get_default_path), so every
// home Surelog's elaborated package compile can reach is armed here, with a
// module function and a $unit function as NEGATIVE controls.
typedef enum { U_A, U_B, U_C } eu_t;              // $unit enum
function eu_t u_ret();                            // $unit free function
  return U_B;
endfunction

package p138c1;
  typedef enum { C_A, C_B, C_C } ec_t;

  function ec_t pf_ret();                         // package free function
    return C_B;
  endfunction

  task pt_t(output ec_t o);                       // a TASK (no return value)
    o = C_B;
  endtask

  class c138c;
    typedef enum { CC_A, CC_B } ecc_t;            // CLASS-SCOPE enum typedef
    extern function ec_t oob_ret();               // OUT-OF-BODY  <-- the head
    extern function ecc_t oob_cls();              // out-of-body, class enum
    extern function ec_t oob_if(int q);           // out-of-body, nested return
    function ec_t inb_ret();                      // IN-BODY method
      return C_C;
    endfunction
    function ecc_t inb_cls();
      return CC_B;
    endfunction
  endclass

  function ec_t c138c::oob_ret();
    return C_B;
  endfunction

  function c138c::ecc_t c138c::oob_cls();
    return CC_B;
  endfunction

  function ec_t c138c::oob_if(int q);
    if (q > 0)
      return C_C;
    return C_A;
  endfunction

endpackage

package p138c2;                                   // WILDCARD-IMPORT clone
  import p138c1::*;
  function ec_t if_ret();
    return C_B;
  endfunction
endpackage

module m138c;                                     // MODULE home (negative)
  typedef enum { M_A, M_B } em_t;
  function em_t mf_ret();
    return M_B;
  endfunction
  function eu_t mu_ret();                         // module fn reading a $unit enum
    return U_B;
  endfunction
  em_t v;
  initial v = mf_ret();
endmodule
