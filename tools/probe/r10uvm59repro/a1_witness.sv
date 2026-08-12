// r10uvm59 a1_witness.sv — THE CORPUS WITNESS, reduced.
//
// AXIS: a STATIC METHOD CALL THROUGH A TYPE PARAMETER (`Tregistry::get()`) in
// the two positions uvm_registry_common actually writes it, next to the
// IDENTICAL spelling through a CONCRETE class (`base59::get()`) as the
// in-arm NEGATIVE CONTROL.
//
// Source shape copied from UVM 1800.2-2017-1.0 uvm_registry.svh
// (pp_output/uvm_pkg.sv 14031-14128), `class uvm_registry_common
// #(type Tregistry=int, type Tcreator=int, ...)`:
//    14073  factory.set_type_override_by_type(Tregistry::get(),ot,replace);   ARGUMENT
//    14096  Tregistry rgtry = Tregistry::get();      ASSIGNMENT RHS, nested begin
//    14104  Tregistry rgtry = Tregistry::get();      ASSIGNMENT RHS, static fn
//    14120  Tregistry rgtry = Tregistry::get();      ASSIGNMENT RHS, virtual fn
//
// PREDICTION (from the golden census, §1 of the README): golden emits ONE
// bare unbound `ref_obj` named `Tregistry::get`, span = start of `Tregistry`
// up to (NOT including) the final identifier `get`, in EVERY position, and
// the CONCRETE spelling takes the SAME shape (which we already emit).
package p59a1;

  virtual class base59;
    static function base59 get();
      return null;
    endfunction
    function void note(base59 w, string s);
    endfunction
    function void initialize();
    endfunction
  endclass

  class w59 #(type Tregistry = int, type Tcreator = int);

    // NEGATIVE CONTROL: the identical spelling through a CONCRETE class.
    static function void concrete_ctl();
      base59 factory = base59::get();
      factory.initialize();
    endfunction

    // ARGUMENT position (corpus 14073 / 14088).
    static function void arg_pos(string nm);
      base59 factory = base59::get();
      factory.note(Tregistry::get(), nm);
    endfunction

    // ASSIGNMENT-RHS position in a STATIC function (corpus 14104) — THE HEAD.
    static function bit deferred_init();
      Tregistry rgtry = Tregistry::get();
      return 1;
    endfunction
    local static bit m_initialized = deferred_init();

    // ASSIGNMENT-RHS position in a VIRTUAL function (corpus 14120).
    virtual function void initialize();
      base59 factory = base59::get();
      Tregistry rgtry = Tregistry::get();
      factory.note(rgtry, "x");
    endfunction

    // ASSIGNMENT-RHS position inside a NESTED begin (corpus 14096).
    static function void set_type_alias(string alias_name);
      if (alias_name != "") begin
        base59 factory = base59::get();
        Tregistry rgtry = Tregistry::get();
        factory.note(rgtry, alias_name);
      end
    endfunction
  endclass
endpackage
