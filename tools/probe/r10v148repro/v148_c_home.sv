// r10v148 arm C — HOMES: package free fn/task, package class in-body and
// out-of-body, $unit class, module class, program, interface, module task,
// a WILDCARD-IMPORT copy, and 1..3 instances of the module.
// MEASUREMENT ONLY.

class unit_cls_v3;                       // $unit-scope class
  int ucp_v3;
  function void ucfn_tf_v3;
    int ucp_v3;
    int shr_v3;
    ucp_v3 = 1;
    shr_v3 = ucp_v3;
  endfunction
endclass

package v3_pkg;
  int shr_v3;
  int oth_v3;

  class pk_cls_v3;
    int shr_v3;
    extern function void ocm_tf_v3;
    extern task          ocm_tk_v3(input int seed);
    function void icm_tf_v3;
      int shr_v3;
      shr_v3 = 1;
      oth_v3 = shr_v3;
    endfunction
  endclass

  function void pfn_tf_v3;
    int shr_v3;
    shr_v3 = 1;
    oth_v3 = shr_v3;
  endfunction

  task ptk_tf_v3;
    input int seed;
    int shr_v3;
    shr_v3 = seed;
    oth_v3 = shr_v3;
  endtask

  function void pk_cls_v3::ocm_tf_v3;
    int shr_v3;
    shr_v3 = 1;
    oth_v3 = shr_v3;
  endfunction

  task pk_cls_v3::ocm_tk_v3;
    input int seed;
    int shr_v3;
    shr_v3 = seed;
    oth_v3 = shr_v3;
  endtask
endpackage


package v3b_pkg;                          // the WILDCARD-IMPORT COPY
  import v3_pkg::*;
  function void qfn_tf_v3;
    int shr_v3;
    shr_v3 = 1;
    oth_v3 = shr_v3;
  endfunction
endpackage

module v148_c_mod;
  int shr_v3;

  class mod_cls_v3;
    int shr_v3;
    function void mcm_tf_v3;
      int shr_v3;
      shr_v3 = 1;
    endfunction
  endclass

  function void mfn_tf_v3;
    int shr_v3;
    shr_v3 = 1;
  endfunction

  task mtk_tf_v3;
    input int seed;
    int shr_v3;
    shr_v3 = seed;
  endtask

  initial mfn_tf_v3();
endmodule

program v148_c_prog;
  int shr_v3;
  function void pgfn_tf_v3;
    int shr_v3;
    shr_v3 = 1;
  endfunction
  initial pgfn_tf_v3();
endprogram

interface v148_c_ifc;
  int shr_v3;
  function void ifn_tf_v3;
    int shr_v3;
    shr_v3 = 1;
  endfunction
endinterface

module v148_c_top;
  v148_c_mod i0();
  v148_c_mod i1();
  v148_c_mod i2();
  v148_c_ifc  f0();
  initial begin
    v3_pkg::pfn_tf_v3();
    v3b_pkg::qfn_tf_v3();
  end
endmodule
