// § matchesOpPattern403
module top;
  typedef union tagged {
    struct { bit [3:0] val1, val2; } a;
    bit [7:0] b;
    void n;
  } u;
  u x; wire [1:0] y;
  assign y = x matches tagged b .v ? 2'd1 : 2'd2;
endmodule
