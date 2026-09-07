// r10uvm192 ARM B — THE CLASS SHAPE: plain / parameterized / nested / derived.
// § pkgTfBodyCmViewClone192.  MEASUREMENT ONLY.
package loomPkg;

  class Plain;
    extern static function int spool();
    extern static function int plainCaller();
  endclass
  function int Plain::spool();
    return 5;
  endfunction
  function int Plain::plainCaller();
    return Plain::spool();
  endfunction

  class Param #(int W = 4);
    extern static function int spool();
    extern static function int paramCaller();
  endclass
  function int Param::spool();
    return W;
  endfunction
  function int Param::paramCaller();
    return Param#(4)::spool();
  endfunction

  // NESTED.  The out-of-body form `function int Outer::Inner::spool();` is
  // REFUSED BY SLANG ("expected subroutine name" / "use of undeclared
  // identifier 'Inner'"), so the nested row is measured with an IN-BODY
  // method: the package listing carries no `Outer::Inner::spool` entry at all
  // and the cell must stay on the class method under both binaries.  The
  // out-of-body nested shape is recorded as UNREACHABLE, not as agreeing.
  class Outer;
    class Inner;
      static function int spool();
        return 9;
      endfunction
    endclass
    extern static function int outerCaller();
  endclass
  function int Outer::outerCaller();
    return Outer::Inner::spool();
  endfunction

  class Base;
    extern static function int spool();
  endclass
  function int Base::spool();
    return 23;
  endfunction

  class Derived extends Base;
    extern static function int derivedCaller();
  endclass
  function int Derived::derivedCaller();
    return Base::spool() + Derived::spool();
  endfunction

  // A caller that reaches ACROSS the class shapes from one body.
  class Mixer;
    extern static function int mix();
  endclass
  function int Mixer::mix();
    return Plain::spool() + Base::spool() + Outer::Inner::spool();
  endfunction

endpackage
