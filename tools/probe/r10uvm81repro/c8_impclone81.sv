// r10uvm81 arm c8 — the IMPORT-CLONE gate of
// § pkgSubRefBindsPkgVarOverFormal81.  A package that wildcard-imports another
// materialises a CLONE of every variable that import makes visible AND a copy
// of its subroutines (SeqDriver's `adpcm_pkg` reproduces uvm_pkg's 33
// variables).  Golden binds `adpcm_pkg::…::set_arbitration::val` to the
// IO_DECL while binding the uvm_pkg twin of the very same statement to
// `uvm_pkg::val`, so a CLONE does not displace a formal.
package p89;
  int sink;
  class c89;
    int    m_a;
    string m_s;
    extern function new();
    extern function void sv89(int val);
  endclass
  function c89::new();
    begin
      string val;                 // hoisted -> p89::val (and cloned into q89)
      val = "x";
      m_s = val;
    end
  endfunction
  function void c89::sv89(int val);
    m_a = val;                    // J1 in p89: the OWN listing -> p89::val
  endfunction
endpackage

package q89;
  import p89::*;
  int qsink;
  class d89;
    int    m_b;
    extern function void qv89(int val);
  endclass
  function void d89::qv89(int val);
    m_b = val;                    // J2 in q89: only the CLONE is visible
  endfunction
endpackage

module mdl89;
  import q89::*;
  import p89::*;
  int mv;
  initial mv = 0;
endmodule
