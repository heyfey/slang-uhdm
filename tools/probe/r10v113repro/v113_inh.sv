// r10v113 / v113_inh.sv — inheritance, nesting, parameterisation and shadowing.
package rinh;
  function automatic int Bolt(int k); return k + 1; endfunction
  function automatic int cinder(int k); return k + 2; endfunction
  function automatic int Yarn(int k); return k + 3; endfunction
  int Bolt_shadow_var = 0;                 // a package VARIABLE, not a sub
  function automatic int Bolt_shadow_var_fn(int k); return k; endfunction

  // ---- base declares the colliding name BELOW the derived's callers ----
  class Base0;
    function int fromBase(); return Bolt(41); endfunction   // base's own caller
    function int Bolt(int k); return k + 500; endfunction   // base method
  endclass

  class Deriv0 extends Base0;
    function int callsInherited(); return Bolt(42); endfunction  // inherited (72)
    function int callsSuper();     return super.Bolt(43); endfunction
    function int callsThis();      return this.Bolt(44); endfunction
  endclass

  // ---- parameterised base ----
  class PBase #(int W = 8);
    function int pcall(); return cinder(51); endfunction     // above PBase::cinder
    function int cinder(int k); return k + W; endfunction
  endclass

  class PDeriv extends PBase #(16);
    function int dcall(); return cinder(52); endfunction     // inherited, below
  endclass

  // ---- nested class: the inner method calls a name that the OUTER class
  //      declares below, and the package also declares.
  class Outer;
    class Inner;
      function int icall(); return Yarn(61); endfunction
    endclass
    function int ocall(); return Yarn(62); endfunction
    static function int Yarn(int k); return k + 700; endfunction
  endclass

  // ---- a class-level VARIABLE shadowing the package function's name ----
  class Shadow;
    int cinder;                                     // a PROPERTY of that name
    function int scall(); return rinh::cinder(71); endfunction  // must stay scoped
  endclass
endpackage

module tb_inh;
  import rinh::*;
  Deriv0 d; PDeriv p; Outer o; Outer::Inner i; Shadow s;
  initial begin d = new(); p = new(); o = new(); i = new(); s = new(); end
endmodule
