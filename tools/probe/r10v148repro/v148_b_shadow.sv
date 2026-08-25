// r10v148 arm B — WHAT THE LOCAL SHADOWS: package variable / class property /
// package parameter / typedef name / module variable / $unit variable.
// Every subroutine below is written BOTH productions where legal.
// MEASUREMENT ONLY.

int unit_var;                       // $unit-scope variable

package v2_pkg;
  parameter int parm_v2 = 3;
  typedef int tnam_v2;
  int pvar_v2;

  class cls_v2;
    int prop_v2;
    int pvar_v2;
    extern function void oob_tf_v2;
    extern function void oob_bk_v2();
    function void inb_tf_v2;
      int prop_v2;
      int pvar_v2;
      prop_v2 = 1;
      pvar_v2 = prop_v2;
    endfunction
    function void inb_bk_v2();
      int prop_v2;
      int pvar_v2;
      prop_v2 = 1;
      pvar_v2 = prop_v2;
    endfunction
  endclass

  function void oob_none_v2;
    int parm_v2;
    int tnam_v2;
    parm_v2 = 1;
    tnam_v2 = parm_v2;
  endfunction

  function void free_tf_v2;
    int pvar_v2;
    int parm_v2;
    pvar_v2 = 2;
    parm_v2 = pvar_v2;
  endfunction

  function void free_bk_v2();
    int pvar_v2;
    int parm_v2;
    pvar_v2 = 2;
    parm_v2 = pvar_v2;
  endfunction

function void cls_v2::oob_tf_v2;
  int prop_v2;
  int pvar_v2;
  prop_v2 = 1;
  pvar_v2 = prop_v2;
endfunction

function void cls_v2::oob_bk_v2();
  int prop_v2;
  int pvar_v2;
  prop_v2 = 1;
  pvar_v2 = prop_v2;
endfunction
endpackage


module v148_b_mod;
  int mvar_v2;
  int unit_var;

  function void mtf_v2;
    int mvar_v2;
    int unit_var;
    mvar_v2 = 5;
    unit_var = mvar_v2;
  endfunction

  function void mbk_v2();
    int mvar_v2;
    int unit_var;
    mvar_v2 = 5;
    unit_var = mvar_v2;
  endfunction

  task mtask_tf_v2;
    input int seed;
    int mvar_v2;
    mvar_v2 = seed;
  endtask

  initial begin
    mtf_v2();
    mbk_v2();
  end
endmodule
