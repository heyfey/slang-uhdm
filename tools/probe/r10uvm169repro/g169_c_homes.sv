// r10uvm169 arm C — THE HOMES: a CLASS METHOD (in-body and out-of-body) in a
// wildcard-imported package, and an EXPLICIT (non-wildcard) import.
// MEASUREMENT ONLY.
//
// § pkgRetOobClassAndImportCloneTs127 names the Reduce::Yes listing set as the
// home package's ELAB listing, the class_defn's own copy of an OUT-OF-BODY
// method body, and BOTH views of a WILDCARD-IMPORT clone.  An IN-BODY method
// is compiled by CompileClass and never sees Reduce::Yes.  An explicit import
// (`import p::f;`) is a different Surelog arm from the wildcard one.
package p169hc;
  parameter int    kc169 = 6;
  parameter string sc169 = "cee";

  class c169;
    function int    m_in169();  return kc169; endfunction
    extern function string m_oob169();
  endclass
  function string c169::m_oob169(); return sc169; endfunction

  function int f_free169(); return kc169; endfunction
endpackage

package p169ec;                 // EXPLICIT import of one symbol
  import p169hc::f_free169;
  parameter int owne169 = 2;
  function int f_owne169(); return owne169; endfunction
endpackage

package p169wc;                 // WILDCARD import of the same package
  import p169hc::*;
  parameter int ownw169 = 4;
  function int f_ownw169(); return ownw169; endfunction
endpackage

module g169_c_homes;
  import p169hc::*;
  import p169ec::*;
  import p169wc::*;
  int    c_i;
  string c_s;
  c169   c_h;
  initial begin
    c_h = new();
    c_i = f_free169() + f_owne169() + f_ownw169() + c_h.m_in169();
    c_s = c_h.m_oob169();
  end
endmodule
