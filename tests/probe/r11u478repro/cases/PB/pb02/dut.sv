// § providerBodyCopyBind478 (an out-of-body class method with three locals)
package u;
  class S; static function S get(); return null; endfunction endclass
  class C;
    extern function new(string name);
  endclass
  function C::new(string name);
    string e;
    S top;
    S cs;
    cs = S::get();
    top = cs;
    e = name;
  endfunction
endpackage
package a;
  import u::*;
  class A; C c; endclass
endpackage
package t;
  import a::*;
  class T; A h; endclass
endpackage
module top; import t::*; T o; endmodule
