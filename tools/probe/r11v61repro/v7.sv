// v11u61 arm v7 — AWAY HUNT: shapes where the PRISTINE binary already matches golden
module v7;
  typedef struct { byte a; byte b; byte c; } e8_t;
  localparam e8_t A1 = '{a: 8'hAB, b: 8'b10100101, c: 8'o17};
  typedef struct { longint x; longint y; } l64_t;
  localparam l64_t L1 = '{x: 1, y: 2};
  typedef struct { byte a; byte b; } s_t;
  localparam s_t S1 = '{a: "A", b: 8'd3};
  localparam int K = 5;
  typedef struct { logic [7:0] p; logic [7:0] q; } r_t;
  localparam r_t R1 = '{p: K, q: K+1};
  typedef struct { byte m; byte n; } f_t;
  localparam f_t F1 = '{m: $clog2(9), n: $bits(byte)};
  typedef struct { bit b1; bit c1; } b1_t;
  localparam b1_t B1 = '{b1: 1'b1, c1: 1'b0};
endmodule
