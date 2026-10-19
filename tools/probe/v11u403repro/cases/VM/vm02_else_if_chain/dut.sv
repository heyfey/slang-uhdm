// § matchesOpPattern403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x; int y;
  initial if (x matches tagged b .v) y = v; else if (x matches tagged n) y = 1; else y = 0;
endmodule
