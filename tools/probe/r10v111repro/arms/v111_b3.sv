// r10v111 ARM B3 — NESTED IMPORTS.  C declares the class; B wildcard-imports C;
// A wildcard-imports BOTH B and C, so A's listing can acquire the same `C::m`
// entry twice and the FIRST-WRITER-WINS map is exercised against Surelog's own
// linear scan.
package v111b3c;
  class Cc3;
    extern static function int deep3();
  endclass
  function int Cc3::deep3();
    deep3 = 33;
  endfunction
  int c_v3 = Cc3::deep3();
endpackage

package v111b3b;
  import v111b3c::*;
  int b_v3 = Cc3::deep3();
endpackage

package v111b3a;
  import v111b3b::*;
  import v111b3c::*;
  int a_v3 = Cc3::deep3();
endpackage
