// v11u61 arm v8 — SETTER ORDER, DEFAULT MIXES, ENUM-TYPED MEMBERS
module v8;
  typedef enum logic [7:0] { EA = 8'd1, EB = 8'd2 } e_t;
  typedef struct { byte b8; e_t e; shortint s16; } m_t;
  localparam m_t M1 = '{s16: 3, b8: 1, e: EB};
  localparam m_t M2 = '{b8: 1, e: EA, s16: 4};
  typedef struct { byte b8; shortint s16; int i32; } t_t;
  localparam t_t T1 = '{b8: 1, s16: 2, default: 9};
  typedef struct { logic [1:0][3:0] pa; byte b; } pa_t;
  localparam pa_t P1 = '{pa: 8'hC3, b: 4};
endmodule
