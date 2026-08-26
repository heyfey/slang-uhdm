// r10uvm156 — DECLARATION-FORM grid.  Every form a class_typespec can hang off,
// in a PACKAGE (where the same-home half of § 156 bites) and in a MODULE.
// Only the FUNCTION-RETURN form is § 156's; every other cell must read the same
// before and after.  MEASUREMENT ONLY; golden = Surelog, LHS is always golden.

package far156;
  class fcls156;
    int fx;
  endclass
  class fpar156 #(type T = int);
    T tv;
  endclass
  typedef fcls156 ftd156;
endpackage

class ucls156;                      // a $unit class
endclass

package hb156;
  import far156::*;
  class sibb156;
  endclass
  class formsB156;
    // ---- forms whose home is the SAME package (arm B hits) ----
    sibb156                 p_var_same;                       // class PROPERTY
    sibb156                 p_arr_same[4];                    // fixed array
    sibb156                 p_que_same[$];                    // queue
    sibb156                 p_dyn_same[];                     // dynamic array
    function sibb156        f_ret_same();  return null; endfunction   // RETURN
    function void           f_arg_same(sibb156 a); endfunction        // FORMAL
    function void           f_loc_same();  sibb156 l; l = null; endfunction // LOCAL
    // ---- the same forms with a FAR-package class ----
    fcls156                 p_var_far;
    fcls156                 p_arr_far[4];
    fcls156                 p_que_far[$];
    fcls156                 p_dyn_far[];
    function fcls156        f_ret_far();   return null; endfunction   // RETURN
    function void           f_arg_far(fcls156 a); endfunction
    function void           f_loc_far();   fcls156 l; l = null; endfunction
    // ---- typedef / parameterized / scoped / $unit forms ----
    ftd156                  p_var_td;                                 // TYPEDEF of a class
    function ftd156         f_ret_td();    return null; endfunction   // typedef RETURN
    fpar156#(int)           p_var_par;                                // specialization
    function fpar156#(int)  f_ret_par();   return null; endfunction
    far156::fcls156         p_var_scoped;                             // scoped pkg::cls
    function far156::fcls156 f_ret_scoped(); return null; endfunction
    // (a $unit class is not referenceable from a package; the $unit axis lives
    //  in the MODULE half below and in g156_a_mech's $unit class)
    class innerb156;                                                  // NESTED class
    endclass
    innerb156               p_var_nested;
    function innerb156      f_ret_nested(); return null; endfunction
    function sibb156        f_ret_castsrc();                          // a CAST target
      sibb156 q;
      q = sibb156'(null);
      return q;
    endfunction
  endclass
  function sibb156 hf_ret_same(); return null; endfunction
  function fcls156 hf_ret_far();  return null; endfunction
endpackage

module modb156;
  import far156::*;
  import hb156::*;
  class mcls156;
  endclass
  class formsM156;
    mcls156                 m_var_same;
    function mcls156        m_ret_same();  return null; endfunction
    function void           m_arg_same(mcls156 a); endfunction
    fcls156                 m_var_far;
    function fcls156        m_ret_far();   return null; endfunction
    function void           m_arg_far(fcls156 a); endfunction
    sibb156                 m_var_pkg;
    function sibb156        m_ret_pkg();   return null; endfunction
    ucls156                 m_var_unit;
    function ucls156        m_ret_unit();  return null; endfunction
  endclass
  function mcls156 mf_ret_same(); return null; endfunction
  function fcls156 mf_ret_far();  return null; endfunction
  formsM156 hm156;
  initial hm156 = new();
endmodule
