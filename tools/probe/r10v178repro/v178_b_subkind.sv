// r10v178 VERIFIER ARM B — SUBROUTINE KIND x CLONE.  MEASUREMENT ONLY.
// free function / free TASK / out-of-body class method / IN-BODY class method /
// a class STATIC method / a function with a DEFAULT ARGUMENT that reads the
// parameter.  The law's home-walk starts at `currentSubSym`; an out-of-body
// method's parent scope is the CLASS and a free subroutine's is the PACKAGE,
// so both halves must be exercised.

package Nu_home_V;
  parameter int poly_nu_V = 32'h0bad_c0de;

  class Kappa_nu_V;
    int acc;
    function automatic int in_body_nu(input int a);   // IN-BODY method
      int r; r = a; r ^= poly_nu_V; return r;
    endfunction
    extern function int oob_nu(input int a);
    extern static function int stat_nu(input int a);
    extern task tsk_nu(input int a, output int b);
  endclass

  function automatic int oob_nu_dummy(); return 0; endfunction

  function int Kappa_nu_V::oob_nu(input int a);   // OUT-OF-BODY
    int r; r = a; r ^= poly_nu_V; return r;
  endfunction
  function int Kappa_nu_V::stat_nu(input int a);
    int r; r = a; r ^= poly_nu_V; return r;
  endfunction
  task Kappa_nu_V::tsk_nu(input int a, output int b);
    b = a; b ^= poly_nu_V;
  endtask

  function automatic int free_fn_nu(input int a);          // FREE FUNCTION
    int r; r = a; r ^= poly_nu_V; return r;
  endfunction
  task automatic free_tsk_nu(input int a, output int b);   // FREE TASK
    b = a; b ^= poly_nu_V;
  endtask
  function automatic int dflt_nu(input int a = poly_nu_V); // DEFAULT ARG reads it
    return a + 1;
  endfunction
endpackage

package Xi_imp_V;                 // ONE wildcard importer -> the clone listing
  import Nu_home_V::*;
endpackage

module m_v178b (input logic ck, output int b1, b2, b3, b4, b5);
  import Nu_home_V::*;
  import Xi_imp_V::*;
  int t1, t2;
  Kappa_nu_V kk = new();
  assign b1 = free_fn_nu(21);
  assign b2 = dflt_nu();
  assign b3 = Kappa_nu_V::stat_nu(23);
  assign b4 = t1;
  assign b5 = t2;
  always_comb begin
    free_tsk_nu(31, t1);
    kk.tsk_nu(32, t2);
  end
endmodule
