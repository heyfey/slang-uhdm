// r10uvm111 GRID ARM A — § pkgVarInitCmViewClone111, the four-cell golden grid
// on 40 lines: WHICH object a PACKAGE-SCOPE VARIABLE INITIALIZER's `C::m()`
// call binds, in the HOME package and in a WILDCARD IMPORTER, in the DEF
// (uhdmallPackages) and the ELABORATED (uhdmtopPackages) view.
//
// Names are deliberately UNLIKE each other and unlike the corpus (no `get`, no
// `uvm_`), and the two out-of-body methods differ in name AND arity so an arm
// that agreed by accident could not read as agreement.
package hpk111;
  class Cee111;
    extern static function int mk111();
    extern static function int other111(int q);
  endclass
  function int Cee111::mk111();
    mk111 = 7;
  endfunction
  function int Cee111::other111(int q);
    other111 = q + 1;
  endfunction
  // the cell: a package-scope variable whose initializer calls `C::m()`
  int rooted111 = Cee111::mk111();
  int second111 = Cee111::other111(3);
endpackage

// A WILDCARD importer: it materializes a clone of hpk111's whole listing,
// out-of-body methods included, and a clone of its variables.
package imp111;
  import hpk111::*;
  int localish111 = 4;
endpackage

// An EXPLICIT (named) importer: it materializes no wildcard clone listing, so
// its variable initializer has no `C::m` entry of its own to bind.
package exp111;
  import hpk111::Cee111;
  int viaexp111 = Cee111::mk111();
endpackage

module m111;
  int w111;
  initial w111 = hpk111::rooted111;
endmodule
