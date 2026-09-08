// r10v205 arm H — THE OWNER-MASK HOLE.  The law's exclusivity guard marks bit 2
// only from a `variables`/`io_decl` whose innermost enclosing object is a
// function or task.  A CLASS PROPERTY (`declTf205` climbs into `class_defn` and
// returns null) and a PACKAGE- or MODULE-level variable (climb reaches
// `package`/`module_inst`) are NEVER marked.  If our emitter ever hands such a
// declaration the SAME element ref as a clone body local, the guard cannot see
// it and the non-clone cell moves with it.  Same type, same package, every
// non-subroutine home for a declaration.
package p205a_h2;
  typedef bit [7:0] bt205;
  bt205 pkgvar205[];                       // PACKAGE-level variable
  class E205;
    bt205 eprop205[];                      // CLASS PROPERTY
    static bt205 esprop205[];              // STATIC class property
    function int em205();
      bt205 eloc205[];                     // a body local of the SAME type
      return eloc205.size() + eprop205.size() + esprop205.size();
    endfunction
  endclass
  function automatic int fh2205(input bt205 hio205[]);
    bt205 hloc205[];
    E205  e205;
    e205 = new();
    return hio205.size() + hloc205.size() + pkgvar205.size() + e205.em205();
  endfunction
endpackage

package p205b_h2;
  import p205a_h2::*;
  function automatic int gh2205();
    bt205 z205[];
    E205  e205;
    e205 = new();
    return fh2205(z205) + e205.em205() + pkgvar205.size();
  endfunction
endpackage

module v205_h_propshare;
  import p205b_h2::*;
  import p205a_h2::*;
  bt205 modvar205[];                       // MODULE-level variable
  int r205;
  initial r205 = gh2205() + modvar205.size();
endmodule
