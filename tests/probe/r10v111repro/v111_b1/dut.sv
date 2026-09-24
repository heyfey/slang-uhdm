// r10v111 ARM B1 — METHOD SHAPES.  Which object a package-scope variable
// initializer's `C::m()` binds when the out-of-body method varies: plain,
// with locals, with a begin-end body, with an explicit return, a packed-vector
// return, and (the CONTROL) a method defined IN-BODY, which materialises no
// `C::m` package listing entry at all.
package v111b1p;
  class Kls1;
    extern static function int fplain();
    extern static function int flocals(int a);
    extern static function int fbegin();
    extern static function int fret();
    extern static function bit [3:0] fvec();
    static function int finbody();
      return 41;
    endfunction
  endclass
  function int Kls1::fplain();
    fplain = 1;
  endfunction
  function int Kls1::flocals(int a);
    int tmp;
    tmp = a;
    flocals = tmp;
  endfunction
  function int Kls1::fbegin();
    begin
      fbegin = 3;
    end
  endfunction
  function int Kls1::fret();
    return 4;
  endfunction
  function bit [3:0] Kls1::fvec();
    fvec = 4'h5;
  endfunction
  int c_plain  = Kls1::fplain();
  int c_locals = Kls1::flocals(2);
  int c_begin  = Kls1::fbegin();
  int c_ret    = Kls1::fret();
  bit [3:0] c_vec = Kls1::fvec();
  int c_inbody = Kls1::finbody();
endpackage

package v111b1w;
  import v111b1p::*;
  int mirror1 = 0;
endpackage

module v111b1m;
  int z1;
  initial z1 = v111b1p::c_plain;
endmodule
