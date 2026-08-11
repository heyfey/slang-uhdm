// r10oth7 arm 3 — the BOUNDARIES the two laws must not cross.
// Arm 2 fixed the class-method-local naming rule to "same HOME DESIGN COMPONENT
// (Package / InstanceBody), with $unit NOT a component".  Implementing it means
// walking the CLASS side up THROUGH nesting ClassType scopes, and walking the
// DECLARATION side up THROUGH the enclosing ClassType.  Both walks touch
// positions arm 2 never measured, so every one of them gets a cell here.
// Also: the BUILT-IN (`mailbox`) local in the non-class positions, since law A's
// "built-ins are never named in a local position" clause was measured only
// inside a class method.
// Run with builtins ON (ctarm.sh default).

class d0_target;                     // a $unit class, for the module cells
  int f;
endclass

package pd;
  class d1_outer;                    // NESTING on the CLASS side, in a package
    class d1_inner;
      int f;
    endclass
  endclass
  class d2_user;                     // ...used from a DIFFERENT class, same pkg
    task t();
      d1_outer::d1_inner v;          // cell d2: nested class, SCOPED spelling
      v = new();
    endtask
  endclass
  class d3_plain;
    int f;
  endclass
  function automatic int d4_pkgfunc();  // PACKAGE FUNCTION, not a class method
    d3_plain a;                      // cell d4: same-package class
    mailbox  b;                      // cell d5: BUILT-IN in a package function
    a = new();
    b = new();
    return 0;
  endfunction
endpackage

package pe;
  class e1_far;                      // a class in ANOTHER package
    int f;
  endclass
endpackage

class d6_user;                       // $unit class reaching into another package
  task t();
    pe::e1_far v;                    // cell d6: scoped, other package
    v = new();
  endtask
endclass

module m3_top;
  class d7_outer;                    // NESTING on the class side, in a MODULE
    class d7_inner;
      int f;
    endclass
  endclass
  function automatic int d8_modfunc();  // MODULE FUNCTION, not a class method
    d7_outer::d7_inner a;            // cell d8: nested same-module class
    d0_target          b;            // cell d9: $unit class
    mailbox            c;            // cell d10: BUILT-IN in a module function
    a = new();
    b = new();
    c = new();
    return 0;
  endfunction
  initial begin
    mailbox   d;                     // cell d11: BUILT-IN in an initial block
    d0_target e;                     // cell d12: $unit class in initial block
    d = new();
    e = new();
    if (d8_modfunc() != 0) $display("x");
  end
  mailbox   f;                       // cell d13: BUILT-IN at module scope
  d0_target g;                       // cell d14: $unit class at module scope
  initial begin
    f = new();
    g = new();
  end
endmodule
