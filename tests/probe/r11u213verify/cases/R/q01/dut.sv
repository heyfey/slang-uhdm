// § tfItemBodyLocal148 (residue check, pass 207's residue 2: a paren-less out-of-body function header; body variables with and without initializers)
package p;
  class K; static function K get(); return null; endfunction endclass
  class C;
    extern function void m1;
    extern function void m2();
  endclass
  function void C::m1;
    static bit first = 1;
    K clp = K::get();
    int plain;
    int init = 3;
  endfunction
  function void C::m2();
    static bit first = 1;
    int init = 3;
  endfunction
endpackage
module top; endmodule
