// r10v106 va2_lhs106 — THE Lhs TYPE ZOO.  `caLhsAdjustBind106` takes slang's
// `getBitWidth()`; Surelog's `adjustSize` takes `Bits(<the Lhs typespec>)`.
// Any type where those two disagree is an AWAY-GOLDEN candidate.  Includes the
// FloatingType::Real arm (the patch hard-codes 32) and the width-1 mints
// (r10earl55 territory).  MEASUREMENT ONLY.
package pv2_106;
  parameter int unsigned P8 = 8;
endpackage

typedef struct packed { logic [3:0] a; logic [2:0] b; } sv2_t;   // 7 bits
typedef enum logic [2:0] { EA = 3'd0, EB = 3'd1 } ev2_t;          // 3 bits
typedef logic [3:0][7:0] pa2_t;                                   // 32 bits

module va2_lhs106 (output logic o);
  sv2_t          v_struct;
  pa2_t          v_parr;
  logic [1:0][2:0] v_parr2;   // 6 bits
  int            v_int;
  integer        v_integer;
  byte           v_byte;
  shortint       v_shortint;
  longint        v_longint;
  bit            v_bit;
  logic          v_scalar;
  logic signed [7:0] v_signed;
  time           v_time;
  real           v_real;
  wire  [7:0]    v_wire;
  wire           v_wire1;

  if (1) begin : t_struct  assign v_struct   = pv2_106::P8'(6'h3F); end
  if (1) begin : t_parr    assign v_parr     = pv2_106::P8'(6'h3F); end
  if (1) begin : t_parr2   assign v_parr2    = pv2_106::P8'(6'h3F); end
  if (1) begin : t_int     assign v_int      = pv2_106::P8'(6'h3F); end
  if (1) begin : t_integer assign v_integer  = pv2_106::P8'(6'h3F); end
  if (1) begin : t_byte    assign v_byte     = pv2_106::P8'(6'h3F); end
  if (1) begin : t_shorti  assign v_shortint = pv2_106::P8'(6'h3F); end
  if (1) begin : t_longi   assign v_longint  = pv2_106::P8'(6'h3F); end
  if (1) begin : t_bit     assign v_bit      = pv2_106::P8'(6'h3F); end
  if (1) begin : t_scalar  assign v_scalar   = pv2_106::P8'(6'h3F); end
  if (1) begin : t_signed  assign v_signed   = pv2_106::P8'(6'h3F); end
  if (1) begin : t_time    assign v_time     = pv2_106::P8'(6'h3F); end
  if (1) begin : t_real    assign v_real     = pv2_106::P8'(6'h3F); end
  if (1) begin : t_wire    assign v_wire     = pv2_106::P8'(6'h3F); end
  if (1) begin : t_wire1   assign v_wire1    = pv2_106::P8'(6'h3F); end
  if (1) begin : t_enum    assign o          = ev2_t'(3'h5); end
endmodule
