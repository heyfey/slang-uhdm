// § patternVarImplicitNet403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x; int y; logic [7:0] v;
  initial if (x matches tagged b .v) y = v;
endmodule
