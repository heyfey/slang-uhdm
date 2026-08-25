// r10v150 fence 1 — a NESTED scope root `pkg::Cls::f().m()`.
package fp1;
  class LL; int y = 1; function int mm(int a); return y+a; endfunction endclass
  class CC; extern static function LL g(); endclass
  function LL CC::g(); LL l = new(); return l; endfunction
endpackage
module TF1;
  function int h1(); return fp1::CC::g().mm(9); endfunction
  function automatic fp1::LL h2(); return fp1::CC::g(); endfunction
  int r; initial r = h1();
endmodule
