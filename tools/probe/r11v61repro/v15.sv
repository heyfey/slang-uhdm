// v11u61 arm v15 — more operand kinds golden may keep unfolded
module v15;
  typedef enum logic [7:0] { EA = 8'd1, EB = 8'd2 } e_t;
  typedef struct { byte a; shortint b; } k_t;
  localparam k_t K1 = '{a: 8'(7), b: 2};
  localparam k_t K2 = '{a: signed'(7), b: 2};
  localparam k_t K3 = '{a: e_t'(1), b: 2};
  localparam k_t K4 = '{a: 3 ** 2, b: 2};
  localparam byte AR [0:1] = '{1, 2};
  localparam k_t K5 = '{a: AR[1], b: 2};
  typedef struct { byte x; byte y; } inner_t;
  localparam inner_t IN = '{x: 5, y: 6};
  localparam k_t K6 = '{a: IN.y, b: 2};
endmodule
