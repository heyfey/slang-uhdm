// v11u61 arm v4 — PATTERN FORMS
module v4;
  typedef struct packed { logic [3:0] p; logic [3:0] q; } pk_t;
  typedef struct { byte b8; pk_t pk; shortint s16; } m_t;
  localparam m_t M1 = '{b8: 1, pk: 8'hA5, s16: 3};
  localparam m_t M2 = '{default: 7};
  localparam m_t M3 = '{1, 8'h3c, 5};
  typedef struct { shortint s; int i; } n_t;
  localparam n_t N1 = '{s: 2, i: 3};
  typedef struct { byte b8; shortint s16; } c_t;
  localparam c_t C1 = '{b8: {2'b10, 2'b01}, s16: {4{2'b11}}};
endmodule
