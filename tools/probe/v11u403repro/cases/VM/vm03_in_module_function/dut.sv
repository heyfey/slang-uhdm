// § patternVarImplicitNet403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x;
  function int f();
    if (x matches tagged b .v) return v;
    return 0;
  endfunction
  int y;
  initial y = f();
endmodule
