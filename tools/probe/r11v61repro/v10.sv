// v11u61 arm v10 — THE NEGATIVE-OPERAND BAIL, isolated
module v10;
  typedef struct { byte a; shortint b; } ab_t;
  localparam ab_t P1 = '{a: -3, b: 2};
  localparam ab_t P2 = '{a: 3, b: -2};
  localparam ab_t P3 = '{a: 3, b: 2};
  typedef struct { byte a; shortint b; int c; } abc_t;
  localparam abc_t Q1 = '{a: -1, b: 2, c: 3};
endmodule
