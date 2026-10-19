// § patternVarImplicitNet403
class C;
  typedef union tagged { int i; void n; } u;
  u x;
  function int f();
    if (x matches tagged i .k) return k;
    return 0;
  endfunction
endclass
module top; C c = new; endmodule
