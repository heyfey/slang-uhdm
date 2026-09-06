// r10v169 arm K — PARAMETERS WHOSE DEF-VIEW Rhs IS NOT A CONSTANT.
// MEASUREMENT ONLY.  The fold copies `pkgParamDefRhs[&param]` — the Rhs THIS
// listing emitted — so a parameter initialised by an OPERATION, a CHAIN of
// them, a concatenation or a system call is where "which listing registered
// the Rhs last" becomes visible, and a clone listing is a new answer to it.
package p169hk;
  parameter int    ka169 = 5;
  parameter int    kb169 = ka169 + 1;
  parameter int    kc169 = kb169 * 2;
  parameter string sk169 = {"ex", "wye"};
  parameter int    kd169 = $clog2(64);
  parameter bit [7:0] ve169 = {4'hA, 4'h5};

  function int    f_ka169(); return ka169; endfunction
  function int    f_kb169(); return kb169; endfunction
  function int    f_kc169(); return kc169; endfunction
  function string f_sk169(); return sk169; endfunction
  function int    f_kd169(); return kd169; endfunction
  function bit [7:0] f_ve169(); return ve169; endfunction
endpackage

package p169ik;
  import p169hk::*;
  parameter int ownk169 = 8;
  function int f_ownk169(); return ownk169; endfunction
endpackage

module v169_k_rhsform;
  import p169hk::*;
  import p169ik::*;
  int k_i; string k_s; bit [7:0] k_v;
  initial begin
    k_i = f_ka169() + f_kb169() + f_kc169() + f_kd169() + f_ownk169();
    k_s = f_sk169();
    k_v = f_ve169();
  end
endmodule
