// § patternVarImplicitNet403
module top();
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    struct { bit [7:0] val1, val2; } b;
    void n;
  } u;
  u tmp;
  bit [3:0] val;
  int x;
  always @(val) if (tmp matches tagged b '{8'd1, .q}) x = q + 1; else x = 0;
endmodule
