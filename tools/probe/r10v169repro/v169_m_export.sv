// r10v169 arm M — EXPORT, an INTERFACE and a PROGRAM.  MEASUREMENT ONLY.
// `pkgImportCloneEmit` is set only at the two PACKAGE clone-emission sites, so
// an interface's or a program's wildcard import must produce no fold at all,
// and a package that RE-EXPORTS what it imported must not double-clone.
package p169hm;
  parameter int    km169 = 19;
  parameter string sm169 = "em";
  function int    f_m169();  return km169; endfunction
  function string f_ms169(); return sm169; endfunction
endpackage

package p169xm;
  import p169hm::*;
  export p169hm::*;
  parameter int ownx169 = 5;
  function int f_ownx169(); return ownx169; endfunction
endpackage

interface if169m;
  import p169hm::*;
  parameter int ifp169 = 29;
  function int f_ifm169();  return km169; endfunction
  function int f_ifp169();  return ifp169; endfunction
endinterface

module v169_m_export;
  import p169hm::*;
  import p169xm::*;
  if169m u_if();
  int m_i; string m_s;
  initial begin
    m_i = f_m169() + f_ownx169() + u_if.f_ifm169() + u_if.f_ifp169();
    m_s = f_ms169();
  end
endmodule
