// r10v169 arm O — NON-PARAMETER RETURNS inside a WILDCARD-IMPORTED package.
// MEASUREMENT ONLY.  The literal arm, the called-sub reuse arm and the
// `foldedRet` registration stay `pkgTopEmit`-fenced, so a clone listing now
// ENTERS the window and must fall straight through it for every return that is
// not a bare package-parameter read.
package p169ho;
  parameter int ko169 = 3;
  typedef enum int { eo_a169 = 5, eo_b169 = 6 } eo169_t;
  const int co169 = 7;
  int vo169 = 8;

  function eo169_t f_enumem169(); return eo_b169;    endfunction   // ENUM MEMBER
  function int     f_constv169(); return co169;      endfunction   // const VARIABLE
  function int     f_var169();    return vo169;      endfunction   // plain variable
  function int     f_lit169();    return 42;         endfunction   // LITERAL
  function int     f_neglit169(); return -7;         endfunction   // NEGATED literal
  function int     f_call169();   return f_lit169(); endfunction   // CALLED SUB
  function int     f_callp169();  return f_ko169();  endfunction   // called param-backed sub
  function int     f_ko169();     return ko169;      endfunction
  function string  f_strlit169(); return "oh";       endfunction
endpackage

package p169io;
  import p169ho::*;
  parameter int owno169 = 2;
  function int f_owno169(); return owno169; endfunction
endpackage

module v169_o_nonparam;
  import p169ho::*;
  import p169io::*;
  int o_i; string o_s;
  initial begin
    o_i = int'(f_enumem169()) + f_constv169() + f_var169() + f_lit169() +
          f_neglit169() + f_call169() + f_callp169() + f_owno169();
    o_s = f_strlit169();
  end
endmodule
