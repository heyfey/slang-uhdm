// v11u61 arm v14 — operands Surelog's reduceExpr may not fold: function calls, casts, ternary
module v14;
  function automatic int dbl(input int x); return x*2; endfunction
  typedef struct { byte a; shortint b; } fc_t;
  localparam fc_t F1 = '{a: dbl(3), b: 2};
  typedef struct { byte a; shortint b; } bt_t;
  localparam bt_t B1 = '{a: $bits(int), b: 2};
  typedef struct { byte a; shortint b; } ct_t;
  localparam ct_t C1 = '{a: byte'(7), b: 2};
  typedef struct { byte a; shortint b; } tn_t;
  localparam tn_t T1 = '{a: 3 > 2 ? 1 : 0, b: 2};
  typedef struct { byte a; shortint b; } st_t;
  localparam st_t S1 = '{a: "Z", b: 2};
endmodule
