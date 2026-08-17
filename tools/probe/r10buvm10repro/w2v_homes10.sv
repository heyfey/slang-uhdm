// r10buvm10 arm w2 — THE SAME POSITION AT EVERY HOME.  The typedef lives in
// pq10; the enum that uses it as its base is declared in the package itself, in
// a class in that package, in a class in ANOTHER package, in a module (via
// import and via a qualified spelling), and in a class in a module.
package pq10;
  typedef bit [7:0] q_t;
  typedef enum q_t { PB0 = 0, PB1 = 1 } pkg_e;      // package scope
  class cin10;
    typedef enum q_t { KB0 = 0, KB1 = 1 } cls_e;    // class INSIDE the home pkg
    cls_e ci;
    function cls_e f(); return KB0; endfunction
  endclass
endpackage

package pr10;
  import pq10::*;
  class cout10;
    typedef enum q_t { OB0 = 0, OB1 = 1 } ocls_e;   // class in ANOTHER pkg, import
    ocls_e oi;
  endclass
  // NOTE: a QUALIFIED enum base (`enum pq10::q_t {...}`) is a SURELOG SYNTAX
  // ERROR (SNT:PA0207 'no viable alternative at input enum pq10::'), so that
  // cell is UNMEASURABLE and is recorded as such rather than guessed at.
endpackage

module mtop10;
  import pq10::*;
  typedef enum q_t { MB0 = 0, MB1 = 1 } mod_e;      // MODULE scope, import
  typedef bit [3:0] loc_t;
  typedef enum loc_t { MO0 = 0, MO1 = 1 } modloc_e; // MODULE-LOCAL typedef base
  mod_e a; modloc_e c;
  pq10::pkg_e d;
  pq10::cin10 e;
  pr10::cout10 g;
  class cmod10;
    typedef enum q_t { XB0 = 0, XB1 = 1 } xcls_e;   // class in a MODULE
    xcls_e xi;
  endclass
  cmod10 i;
endmodule
