// r10v111 ARM B2 — IMPORTER SHAPES.  Home package, TWO wildcard importers (one
// of which never names the class), an EXPLICIT class import, a MODULE that
// wildcard-imports, and a package that spells the call fully qualified
// `pkg::Cls::m()`.
package v111b2home;
  class Zed2;
    extern static function int mk2();
  endclass
  function int Zed2::mk2();
    mk2 = 11;
  endfunction
  int home_v2 = Zed2::mk2();
endpackage

package v111b2impa;
  import v111b2home::*;
  int a_v2 = Zed2::mk2();
endpackage

package v111b2impb;
  import v111b2home::*;
  int b_v2 = 5;
endpackage

package v111b2expl;
  import v111b2home::Zed2;
  int e_v2 = Zed2::mk2();
endpackage

package v111b2qual;
  int q_v2 = v111b2home::Zed2::mk2();
endpackage

module v111b2mod;
  import v111b2home::*;
  int m_v2 = Zed2::mk2();
endmodule
