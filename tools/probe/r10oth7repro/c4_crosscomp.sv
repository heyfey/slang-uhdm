// r10oth7 arm 4 — the CROSS-COMPONENT class-method locals, i.e. exactly the
// cells where law B's new rule DISAGREES with the shipped blanket suppression.
// Arm 2 measured only the SAME-component and the $unit-vs-$unit cases; these
// are the ones where the declaration's home component and the class's home
// component are BOTH real and DIFFERENT, so the new rule says NAMED where the
// old one said UNNAMED.  A law that only ever saw one spelling has an
// unmeasured half; this is that half.
// Run with builtins ON (ctarm.sh default).

class f0_unit;                       // a $unit class
  int f;
endclass

package pf;
  class f1_pkgcls;                   // a class in package pf
    int f;
  endclass
  // cell e2 (pkg-class method whose local is a $unit class) is UNMEASURABLE:
  // slang rejects it as "cannot reference compilation unit item from within a
  // package", and so does the LRM.  Recorded rather than claimed.
  class f2_user;
    task t();
      f1_pkgcls v;                   // cell e2': same-package control
      v = new();
    endtask
  endclass
endpackage

package pg;
  import pf::f1_pkgcls;
  class g1_user;                     // a class in package pg whose method local
    task t();                        // is a class IMPORTED from package pf
      f1_pkgcls v;                   // cell e3: pkg -> OTHER pkg, bare name
      v = new();
    endtask
  endclass
  class g2_base;
    int b;
  endclass
  class g3_ext extends g2_base;      // an EXTENDED class in the same package
    task t();
      g2_base v;                     // cell e6: base class, same package
      v = new();
    endtask
  endclass
endpackage

module m4_top;
  class h1_user;                     // a class declared INSIDE a module whose
    task t();                        // method local is a $unit class
      f0_unit v;                     // cell e1: module-class method -> $unit
      v = new();
    endtask
    task t2();
      pf::f1_pkgcls w;               // cell e4: module-class method -> package
      w = new();
    endtask
  endclass
  h1_user u;
  initial begin
    u = new();
    u.t();
    u.t2();
  end
endmodule
