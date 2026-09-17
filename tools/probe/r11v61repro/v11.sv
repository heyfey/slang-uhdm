// v11u61 arm v11 — WHERE EXACTLY THE NEGATIVE BAIL STARTS
module v11;
  typedef struct { int a; shortint b; } si_t;
  localparam si_t A1 = '{a: 32'hFFFFFFFF, b: 2};
  typedef struct { int unsigned a; shortint b; } ui_t;
  localparam ui_t A2 = '{a: 32'hFFFFFFFF, b: 2};
  typedef struct { byte a; shortint b; } bs_t;
  localparam bs_t A3 = '{a: 8'shFF, b: 2};
  typedef struct { logic signed [7:0] a; shortint b; } ls_t;
  localparam ls_t A4 = '{a: -1, b: 2};
  typedef struct { byte a; shortint b; } ar_t;
  localparam ar_t A5 = '{a: 2-5, b: 2};
endmodule
