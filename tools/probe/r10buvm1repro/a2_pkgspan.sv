// r10buvm1 arm a2 — THE PACKAGE-QUALIFIED SPAN AXIS, and the HEAD IN MINIATURE.
//
// a1 showed that for a `pkg::var` receiver golden spans the QUALIFIER ALONE
// (`p1::`, ending at the column the final identifier starts on) while we span
// the WHOLE written name.  That difference is invisible in a1's chain cells
// until the chain collapses at all, so this arm separates the two questions:
//
//   * is the qualifier-only span a property of the CHAIN, or of EVERY
//     package-qualified variable reference (bare read included)?
//   * does it depend on whether the reference is written INSIDE the declaring
//     package (where the corpus head sits — `uvm_pkg::uvm_deferred_init` is
//     written inside `uvm_pkg`) or OUTSIDE it?
//
// H1 is the corpus head in miniature: a static method of a class in the SAME
// package pushing onto a package queue through the package's own qualifier.
package p2;
  int pcnt;
  int pq[$];
  class inner2;
    static function bit hset();
      p2::pq.push_back(7);      // H1 — the corpus head's exact shape
      p2::pcnt = 8;             // H2 — lvalue, inside the package
      return 1;
    endfunction
    static function int hget();
      int y;
      y = p2::pcnt;             // H3 — BARE read, inside the package
      y += p2::pq.size();       // H4 — chain read, inside the package
      return y;
    endfunction
  endclass
  function automatic int pf2();
    int y;
    y = p2::pcnt;               // H5 — BARE read, package free function
    p2::pq.push_back(9);        // H6 — chain stmt, package free function
    return y;
  endfunction
endpackage

module m2;
  int z;
  function automatic int g2();
    int y;
    y = p2::pcnt;               // K1 — BARE read, OUTSIDE the package
    p2::pcnt = 5;               // K2 — lvalue, OUTSIDE the package
    y += p2::pq.size();         // K3 — chain read, OUTSIDE the package
    p2::pq.push_back(6);        // K4 — chain stmt, OUTSIDE the package
    y += p2::inner2::hget();    // K5 — three-segment scoped call
    return y;
  endfunction
  initial z = g2();
endmodule
