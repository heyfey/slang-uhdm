// r10v192 ARM F — CONSTRUCTORS AND VIRTUAL OUT-OF-BODY METHODS, CALLED
// CLASS-QUALIFIED from a package-listed body.  MEASUREMENT ONLY.
package ctorP;
  class Base;
    int x;
    extern function new(int v);
    extern virtual function int val();
    extern static function int mk();
    extern static function int baseCaller();
  endclass
  function Base::new(int v);
    x = v;
  endfunction
  function int Base::val();
    return x;
  endfunction
  function int Base::mk();
    return 71;
  endfunction
  function int Base::baseCaller();
    Base b;
    b = new(3);
    return Base::mk() + b.val();
  endfunction

  class Deriv extends Base;
    extern function new(int v);
    extern virtual function int val();
    extern static function int derivCaller();
  endclass
  function Deriv::new(int v);
    super.new(v);
  endfunction
  function int Deriv::val();
    return super.val() + 1;
  endfunction
  function int Deriv::derivCaller();
    return Base::mk() + Deriv::mk();
  endfunction
endpackage
