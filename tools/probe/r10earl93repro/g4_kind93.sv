// r10earl93 g4 -- THE TARGET-KIND GRID.  Every cast target spelling, at the
// SAME operand, so the fence "only the integer arm masks" is measured and not
// assumed.  MEASUREMENT ONLY.
package g4_pkg;
  typedef logic [63:0] w64_t;
  typedef logic [95:0] w96_t;
  typedef bit   [63:0] b64_t;
  typedef enum logic [63:0] { E0 = 64'd0, E1 = 64'd1 } e64_t;
endpackage
module g4;
  localparam int unsigned PW64 = 64;
  localparam logic [63:0]  SRCA = 64'hFFFFFFFFFFFFFFFF;
  // the integer arm (a SIZE cast): the family
  localparam k_size64 = 64'(64'hFFFFFFFFFFFFFFFF);
  localparam k_sizep  = PW64'(64'hFFFFFFFFFFFFFFFF);
  // keyword type casts: their OWN ExprEval arms, no mask
  localparam k_int     = int'(64'hFFFFFFFFFFFFFFFF);
  localparam k_longint = longint'(64'hFFFFFFFFFFFFFFFF);
  localparam k_shortint= shortint'(64'hFFFFFFFFFFFFFFFF);
  localparam k_byte    = byte'(64'hFFFFFFFFFFFFFFFF);
  localparam k_bit     = bit'(64'hFFFFFFFFFFFFFFFF);
  localparam k_logic   = logic'(64'hFFFFFFFFFFFFFFFF);
  localparam k_integer = integer'(64'hFFFFFFFFFFFFFFFF);
  localparam k_time    = time'(64'hFFFFFFFFFFFFFFFF);
  // typedef'd and enum targets
  localparam k_td64    = g4_pkg::w64_t'(64'hFFFFFFFFFFFFFFFF);
  localparam k_td96    = g4_pkg::w96_t'(64'hFFFFFFFFFFFFFFFF);
  localparam k_tdb64   = g4_pkg::b64_t'(64'hFFFFFFFFFFFFFFFF);
  localparam k_enum    = g4_pkg::e64_t'(64'd1);
  // signed operands take ExprEval's oper_signed branch
  localparam k_s64     = 64'(signed'(64'hFFFFFFFFFFFFFFFF));
  localparam k_s96     = 96'(signed'(64'hFFFFFFFFFFFFFFFF));
  localparam k_sd64    = 64'(64'shFFFFFFFFFFFFFFFF);
  localparam k_sd96    = 96'(64'shFFFFFFFFFFFFFFFF);
  // an x/z operand: get_value invalidates and golden keeps the cast
  localparam k_xz64    = 64'(64'hx);
  localparam k_xz96    = 96'(64'hx);
  // a 96-bit operand with a SMALL value: does get_value bail on the WIDTH or
  // on the VALUE not fitting?
  localparam k_w96small = 96'(96'd5);
  localparam k_w65small = 65'(65'd5);
  localparam k_w64max   = 64'(64'hFFFFFFFFFFFFFFFF);
endmodule
