// r10uvm169 arm A — THE WILDCARD-IMPORT CLONE'S RETURN FOLD, one function per
// PARAMETER KIND.  MEASUREMENT ONLY.
//
// p169h is the HOME package: its own DEF listing must KEEP the `ref_obj`
// (Surelog's `getUnElabPackage()` compile is Reduce::No) and its ELAB listing
// must FOLD (§ pkgRetParamSubstIsRhsClone120, already landed).  p169i
// WILDCARD-IMPORTS it, so `CompileHelper::importPackage` clone_trees the
// ELABORATED home task_funcs into BOTH of p169i's listings — the cells this
// pass turns on.
package p169h;
  parameter string    s_str169 = "ess";
  parameter int       s_int169 = 7;
  localparam int      s_loc169 = 9;
  parameter           s_unt169 = 21;
  parameter byte      s_byt169 = 8'sd5;
  parameter real      s_rel169 = 1.5;
  parameter bit [3:0] s_vec169 = 4'b1010;
  parameter string    s_mty169 = "";
  typedef enum int { ea169 = 3, eb169 = 4 } e169_t;
  parameter e169_t    s_enu169 = eb169;
  typedef bit [5:0] v169_t;
  parameter v169_t    s_typ169 = 6'h2a;

  function string    f_str169(); return s_str169; endfunction
  function int       f_int169(); return s_int169; endfunction
  function int       f_loc169(); return s_loc169; endfunction
  function int       f_unt169(); return s_unt169; endfunction
  function byte      f_byt169(); return s_byt169; endfunction
  function real      f_rel169(); return s_rel169; endfunction
  function bit [3:0] f_vec169(); return s_vec169; endfunction
  function string    f_mty169(); return s_mty169; endfunction
  function e169_t    f_enu169(); return s_enu169; endfunction
  function v169_t    f_typ169(); return s_typ169; endfunction
endpackage

package p169i;
  import p169h::*;
  parameter int own169 = 3;
  // p169i's OWN function over its OWN parameter: the home-package control in
  // the very listing the clones land in.
  function int f_own169(); return own169; endfunction
endpackage

module g169_a_import;
  // A WILDCARD import is not re-exported (LRM 26.3), so the module names both
  // packages: p169h for the home functions, p169i for its own.
  import p169h::*;
  import p169i::*;
  string  a_s;
  int     a_i;
  byte    a_b;
  real    a_r;
  bit [3:0] a_v;
  int     a_o;
  initial begin
    a_s = f_str169();
    a_i = f_int169();
    a_b = f_byt169();
    a_r = f_rel169();
    a_v = f_vec169();
    a_o = f_own169();
  end
endmodule
