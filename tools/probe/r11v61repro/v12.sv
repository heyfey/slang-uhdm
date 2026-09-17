// v11u61 arm v12 — the fence boundary: unsigned wrap, unary-minus-on-literal, mid-pattern negative
module v12;
  typedef struct { byte a; shortint b; } uw_t;
  localparam uw_t U1 = '{a: 8'd2 - 8'd5, b: 2};
  typedef struct { byte a; shortint b; } nl_t;
  localparam nl_t U2 = '{a: -8'sd3, b: 2};
  localparam int PK = 7;
  typedef struct { shortint a; shortint b; } pp_t;
  localparam pp_t U3 = '{a: PK, b: 2};
  typedef struct { byte a; byte b; byte c; } nn_t;
  localparam nn_t U4 = '{a: 1, b: -2, c: 3};
endmodule
