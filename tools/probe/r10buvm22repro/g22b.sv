// r10buvm22 — GRID B: the WRITTEN BASE TYPE axis of an unpacked-array typedef
// return, plus the no-dimension arm of the same Surelog rule.
// MEASUREMENT ONLY.  Cell name = <home>_<shape>.
package q22;
  typedef int qi_t;
  typedef struct packed { logic [3:0] a; } qs_t;
  typedef enum logic [1:0] { QA, QB } qe_t;
  class D22; int x; endclass

  // PACKAGE-scope typedefs with dims, by WRITTEN BASE
  typedef struct packed { logic [3:0] a; } bq_inlstruct_t[$];  // inline struct base
  typedef enum logic [1:0] { EA, EB }      bq_inlenum_t[$];    // inline enum base
  typedef logic [7:0]                      bq_vec_t[$];        // vector base
  typedef qs_t                             bq_tdstruct_t[$];   // NAMED struct td base
  typedef qe_t                             bq_tdenum_t[$];     // NAMED enum td base
  typedef qi_t                             bq_tdint_t[$];      // NAMED int td base
  typedef string                           bq_str_t[$];        // string base

  function bq_inlstruct_t bf_q_inlstruct(); endfunction
  function bq_inlenum_t   bf_q_inlenum();   endfunction
  function bq_vec_t       bf_q_vec();       endfunction
  function bq_tdstruct_t  bf_q_tdstruct();  endfunction
  function bq_tdenum_t    bf_q_tdenum();    endfunction
  function bq_tdint_t     bf_q_tdint();     endfunction
  function bq_str_t       bf_q_str();       endfunction

  class L22;
    // CLASS-scope typedefs with dims, by WRITTEN BASE
    typedef struct packed { logic [3:0] a; } cq_inlstruct_t[$];
    typedef enum logic [1:0] { CA, CB }      cq_inlenum_t[$];
    typedef logic [7:0]                      cq_vec_t[$];
    typedef string                           cq_str_t[$];
    typedef qs_t                             cq_tdstruct_t[$];
    typedef qe_t                             cq_tdenum_t[$];
    typedef qi_t                             cq_tdint_t[$];
    // CLASS-scope typedefs with NO dims (the no-dimension arm)
    typedef qs_t cn_tdstruct_t;
    typedef qe_t cn_tdenum_t;
    typedef qi_t cn_tdint_t;
    typedef struct packed { logic [3:0] a; } cn_inlstruct_t;
    typedef logic [7:0] cn_vec_t;

    function cq_inlstruct_t lc_q_inlstruct(); endfunction
    function cq_inlenum_t   lc_q_inlenum();   endfunction
    function cq_vec_t       lc_q_vec();       endfunction
    function cq_str_t       lc_q_str();       endfunction
    function cq_tdstruct_t  lc_q_tdstruct();  endfunction
    function cq_tdenum_t    lc_q_tdenum();    endfunction
    function cq_tdint_t     lc_q_tdint();     endfunction
    function cn_tdstruct_t  lc_n_tdstruct();  lc_n_tdstruct = 0; endfunction
    function cn_tdenum_t    lc_n_tdenum();    lc_n_tdenum = QA;  endfunction
    function cn_tdint_t     lc_n_tdint();     lc_n_tdint = 0;    endfunction
    function cn_inlstruct_t lc_n_inlstruct(); lc_n_inlstruct = 0; endfunction
    function cn_vec_t       lc_n_vec();       lc_n_vec = 0;      endfunction
  endclass

  // a type parameter BOUND TO A CLASS, queue-typedef'd
  class H22 #(type T = D22);
    typedef T hq_t[$];
    function hq_t hc_q_tp(); endfunction
  endclass
endpackage

module topb22;
  import q22::*;
  L22 l1; H22 #(D22) h1;
  initial begin l1 = new(); h1 = new(); end
endmodule
