// r10buvm1 arm a5 — THE UNBOUND-BODY AXIS, and it is the corpus head.
//
// a4 proved the generic class is NOT the discriminator: a `::`-scoped built-in
// method call inside a generic class's default specialization collapses.  What
// is left of the corpus site is that slang cannot BIND its call at all:
//
//     class uvm_registry_common #(type Tregistry=int, ...);
//       static function bit __deferred_init();
//         Tregistry rgtry = Tregistry::get();          <- Tregistry is `int` here
//         uvm_pkg::uvm_deferred_init.push_back(rgtry); <- pushing an int into a
//       ...                                               queue of class handles
//
// In the DEFAULT specialization the argument's type is the type parameter's
// DEFAULT (`int`) and the queue holds `uvm_object_wrapper` handles, so slang
// rejects the call and the statement reaches the emitter as SYNTAX, never as a
// bound CallExpression.  § scopedBuiltinRecvIsChain1 lives on the AST path and
// cannot see it there.
//
// Q1 is that shape exactly; Q2 is the same call with an argument the default
// specialization DOES accept (the bound control that a4/N2 already covers);
// Q3 is the unbound form in EXPRESSION position.
package p5;
  typedef class w5;
  w5 dq5[$];
  class w5;
    function void initialize();
    endfunction
  endclass
  class reg5 #(type Tregistry = int);
    static function bit dinit();
      Tregistry rgtry;
      p5::dq5.push_back(rgtry);      // Q1 — UNBOUND: int pushed into a w5 queue
      return 1;
    endfunction
    static function bit dok();
      w5 good;
      p5::dq5.push_back(good);       // Q2 — BOUND control, same statement shape
      return 1;
    endfunction
    static function int dexp();
      Tregistry rgtry;
      int y;
      y = p5::dq5.size();            // Q3 — bound expression form
      return y;
    endfunction
    local static bit m5 = dinit();
  endclass
endpackage

module m5;
  int z;
  initial z = 0;
endmodule
