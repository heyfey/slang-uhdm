// r10v169 arm E — SHADOWING inside a WILDCARD-IMPORTED package.  MEASUREMENT ONLY.
// § pkgRetParamSubstIsRhsClone120's name-keyed half substitutes a function
// LOCAL or a FORMAL that carries a package parameter's name.  This pass
// widens the fold window to the clone listings, so the name-keyed half now
// fires there too — this arm asks golden whether it should.
package p169he;
  parameter int    ke169 = 5;
  parameter string se169 = "eee";
  function int    f_ctl169();                  return ke169; endfunction
  function int    f_formal169(input int ke169); return ke169; endfunction
  function int    f_local169();  int ke169; ke169 = 9; return ke169; endfunction
  function string f_cstloc169(); const string se169 = "loc"; return se169; endfunction
  function string f_cstpar169(); return se169; endfunction
endpackage

package p169ie;
  import p169he::*;
  parameter int owne2169 = 1;
  function int f_owne2169(); return owne2169; endfunction
endpackage

module v169_e_shadow;
  import p169he::*;
  import p169ie::*;
  int e_i; string e_s, e_t;
  initial begin
    e_i = f_ctl169() + f_formal169(3) + f_local169() + f_owne2169();
    e_s = f_cstloc169();
    e_t = f_cstpar169();
  end
endmodule
