// § matchesOpPattern403
module top();
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    struct { bit [7:0] val1, val2; } b;
    void n;
  } u;
  u tmp;
  bit [3:0] val;
  int x;
  initial if (tmp matches tagged a '{4'd1, 4'd2}) x = 1;
endmodule
