// r10v169 arm L — CLASS HOMES inside a WILDCARD-IMPORTED package: a STATIC
// method, an out-of-body method over a CLASS-scope localparam, a method over
// the PACKAGE parameter, and a parameterised class.  MEASUREMENT ONLY.
package p169hl;
  parameter int    kl169 = 13;
  parameter string sl169 = "ell";

  class c169l;
    localparam int cl169 = 21;
    static function int s_stat169();  return kl169; endfunction
    function int        m_in169();    return kl169; endfunction
    function int        m_cls169();   return cl169; endfunction
    extern function string m_oob169();
    extern function int    m_oobc169();
  endclass
  function string c169l::m_oob169();  return sl169; endfunction
  function int    c169l::m_oobc169(); return cl169; endfunction

  class c169p #(parameter int P169 = 31);
    function int m_par169(); return P169; endfunction
    extern function int m_oobp169();
  endclass
  function int c169p::m_oobp169(); return kl169; endfunction

  function int f_freel169(); return kl169; endfunction
endpackage

package p169il;
  import p169hl::*;
  parameter int ownl169 = 9;
  function int f_ownl169(); return ownl169; endfunction
endpackage

module v169_l_class;
  import p169hl::*;
  import p169il::*;
  int l_i; string l_s;
  c169l h;
  c169p #(.P169(41)) hp;
  initial begin
    h = new(); hp = new();
    l_i = c169l::s_stat169() + h.m_in169() + h.m_cls169() + h.m_oobc169() +
          hp.m_par169() + hp.m_oobp169() + f_freel169() + f_ownl169();
    l_s = h.m_oob169();
  end
endmodule
