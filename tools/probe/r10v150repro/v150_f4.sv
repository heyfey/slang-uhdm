// r10v150 fence 4 — a PARENTHESISED receiver  `(Cls::f()).m()`.
package fp4;
  class LL; int y = 1; function int mm(int a); return y+a; endfunction endclass
  class CC; extern static function LL g(); endclass
  function LL CC::g(); LL l = new(); return l; endfunction
  function LL bmk(); LL l = new(); return l; endfunction
endpackage
module TF4;
  import fp4::*;
  function int h1(); return (CC::g()).mm(9);  endfunction
  function int h2(); return (bmk()).mm(8);    endfunction
  int r; initial r = h1();
endmodule
