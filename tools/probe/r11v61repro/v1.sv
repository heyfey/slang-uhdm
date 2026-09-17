// v11u61 arm v1 — ENUM EDGE CASES at a module-own elaborated site
package ep1;
  typedef enum logic [3:0] { PA = 4'd1, PB = PA + 1 } pe_t;
endpackage

module v1;
  import ep1::*;
  typedef enum logic [3:0] { LA = 4'd3, LB = LA + 1, LC = LB + 1 } le_t;
  typedef enum logic signed [3:0] { NA = -4'sd2, NB = NA - 1 } ne_t;
  typedef enum logic [39:0] { WA = 40'd7, WB = WA + 1 } we_t;
  typedef struct { byte b8; shortint s16; int i32; } s_t;
  localparam s_t E1 = '{b8: LB, s16: LC, i32: LB};
  localparam s_t E2 = '{b8: NB, s16: NB, i32: NB};
  localparam s_t E3 = '{b8: PB, s16: PB, i32: PB};
  localparam s_t E4 = '{b8: LA, s16: LA, i32: LA};
  localparam s_t E5 = '{b8: WB, s16: WB, i32: WB};
endmodule
