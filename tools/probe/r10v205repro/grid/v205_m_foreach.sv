// r10v205 arm M — THE OWNER-MASK HOLE, DRIVEN.  `declTf205` marks bit 2 only
// from a declaration whose innermost enclosing object is a function or task, so
// a CLASS PROPERTY (the climb stops at `class_defn` and returns null) and a
// PACKAGE-level variable (the climb reaches `package`) are never marked.  R1
// says our emitter hands ONE element ref to a declaration and to the `foreach`
// REFERENCE VARIABLE that walks it.  This arm puts the `foreach` inside a
// WILDCARD-IMPORT CLONE body and walks a class property and a package variable
// — every ref the clone body's reference variables reach is bit 1, and if the
// property's / package variable's own element ref is that same object the
// guard cannot see the other owner and the home cell moves.
package p205a_m;
  typedef bit [7:0] bt205;
  bt205 mpkgq205[$];
  class F205;
    bt205 fq205[$];
    bt205 fd205[];
  endclass
  function automatic int fm205(F205 f205);
    int s205 = 0;
    foreach (f205.fq205[i205]) s205 += int'(f205.fq205[i205]);
    foreach (f205.fd205[j205]) s205 += int'(f205.fd205[j205]);
    foreach (mpkgq205[k205])   s205 += int'(mpkgq205[k205]);
    return s205;
  endfunction
endpackage

package p205b_m;
  import p205a_m::*;
  function automatic int gm205();
    F205 f205;
    int s205 = 0;
    f205 = new();
    foreach (f205.fq205[i205]) s205 += int'(f205.fq205[i205]);
    foreach (mpkgq205[k205])   s205 += int'(mpkgq205[k205]);
    return s205 + fm205(f205);
  endfunction
endpackage

module v205_m_foreach;
  import p205b_m::*;
  import p205a_m::*;
  int r205;
  initial r205 = gm205();
endmodule
