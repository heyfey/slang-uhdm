// r10buvm1 arm a4 — THE GENERIC-CLASS AXIS: the corpus head is inside a
// PARAMETERIZED class's DEFAULT specialization.
//
// a2's H1 (`p2::pq.push_back(7);` in a static method of a PLAIN class inside the
// declaring package) is the head's shape and § scopedBuiltinRecvIsChain1 clears
// it — yet the corpus head did NOT move.  The one structural difference left is
// that `uvm_registry_common` is a GENERIC class (`class uvm_registry_common
// #(type Tregistry=int, ...)`), whose default specialization slang does not
// bind and whose body this emitter therefore re-emits FROM SYNTAX.
//
// N1 is the plain-class positive control (must stay collapsed), N2 the same
// statement inside a generic class's default specialization, N3 the same inside
// a generic class that IS specialized somewhere, N4 the expression form.
package p4;
  int pq4[$];
  int cnt4;
  class plain4;
    static function bit pset();
      p4::pq4.push_back(1);          // N1 — plain class, control
      return 1;
    endfunction
  endclass
  class gen4 #(type T = int, string NM = "x");
    static function bit gset();
      p4::pq4.push_back(2);          // N2 — GENERIC class, default spec
      return 1;
    endfunction
    static function int gget();
      int y;
      y = p4::pq4.size();            // N3 — GENERIC class, expression form
      y += p4::cnt4;                 // N4 — GENERIC class, BARE scoped read
      return y;
    endfunction
    local static bit ginit = gset();
  endclass
  class user4;
    static function int u4();
      gen4#(int, "a") g = new();
      return gen4#(int, "a")::gget();
    endfunction
  endclass
endpackage

module m4;
  int z;
  initial z = p4::user4::u4();
endmodule
