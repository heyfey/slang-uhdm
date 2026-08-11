// r10oth7 arm 2 — HALF B: WHICH class-method body local keeps its vpiName.
// The shipped rule (`localClassTsUnnamed15` / `inClassMethod0` in
// src/TypeEmit.cpp) unnames EVERY class-method body local.  Arm 1 cell a13_user
// already refutes that for a $unit class, so this arm bounds the rule: same
// declaration in eight different (class home, method home, nesting) positions.
// Every cell is a class_typespec at a class-METHOD position.
// Run with builtins ON (ctarm.sh default).

class b1_target;                 // a $unit class
  int f;
endclass

package pb;
  class b2_target;               // a class in a PACKAGE
    int f;
  endclass

  class b2_user;                 // ...and a method local of it, SAME package
    task t();
      b2_target v;               // cell b2: same-package class, bare name
      v = new();
    endtask
  endclass

  class b3_outer;                // NESTED: inner declared inside the user class
    class b3_inner;
      int f;
    endclass
    task t();
      b3_inner v;                // cell b3: nested class, bare name
      v = new();
    endtask
  endclass

  class b4_self;                 // the local's type IS the enclosing class
    task t();
      b4_self v;                 // cell b4: self-reference
      v = new();
    endtask
  endclass
endpackage

class b5_user;                   // $unit user class with $unit-class locals
  task t();
    b1_target v;                 // cell b5: $unit class, bare name (SVSwitch)
    v = new();
  endtask
  task t2();
    begin
      b1_target w;               // cell b6: one `begin` DEEPER
      w = new();
    end
  endtask
  function b1_target t3();       // cell b7: the RETURN type
    b1_target r;                 // cell b8: local beside a return of same type
    r = new();
    return r;
  endfunction
endclass

import pb::b2_target;            // an IMPORTED package class as a method local
class b9_user;
  task t();
    b2_target v;                 // cell b9: imported class, bare name
    v = new();
  endtask
endclass

module m2_top;
  class b10_inmod;               // a class declared INSIDE a module
    int f;
  endclass
  class b11_user;
    task t();
      b10_inmod v;               // cell b11: same-module class, bare name
      v = new();
    endtask
  endclass
  b11_user u;
  initial begin
    u = new();
    u.t();
  end
endmodule
