// r10earl52 arm a1 — TARGET TYPE x {ternary, direct} for the SAME source
// literal 1'b1.  The corpus head is `localparam int FifoPass = PipeLine ? 1'b0
// : 1'b1` where golden reads INT:-1 size 32 and we read BIN:1 size 32.
//
// Every T* row is `C ? 1'b0 : 1'b1` (C is a module parameter = 0, so the ELSE
// branch 1'b1 is taken); every D* row is the same target type written with the
// taken literal DIRECTLY.  If Surelog's param_assign Rhs is "the taken branch,
// then adjustSize against the target typespec", T* and D* must be
// BYTE-IDENTICAL in every row, and the `int` rows must be the only negative
// ones.
module a1_earl52 #(parameter bit C = 1'b0) ();
  // --- int (the head's target)
  localparam int               T_int   = C ? 1'b0 : 1'b1;
  localparam int               D_int   =              1'b1;
  // --- int unsigned
  localparam int unsigned      T_intu  = C ? 1'b0 : 1'b1;
  localparam int unsigned      D_intu  =              1'b1;
  // --- integer (predefined, signed, but NOT `int`)
  localparam integer           T_integ = C ? 1'b0 : 1'b1;
  localparam integer           D_integ =              1'b1;
  // --- byte / shortint / longint (signed predefined, no adjustSize arm)
  localparam byte              T_byte  = C ? 1'b0 : 1'b1;
  localparam byte              D_byte  =              1'b1;
  localparam shortint          T_shrt  = C ? 1'b0 : 1'b1;
  localparam shortint          D_shrt  =              1'b1;
  localparam longint           T_long  = C ? 1'b0 : 1'b1;
  localparam longint           D_long  =              1'b1;
  // --- logic vector / logic scalar
  localparam logic [31:0]      T_lv32  = C ? 1'b0 : 1'b1;
  localparam logic [31:0]      D_lv32  =              1'b1;
  localparam logic             T_lg1   = C ? 1'b0 : 1'b1;
  localparam logic             D_lg1   =              1'b1;
  localparam logic signed [31:0] T_lsv = C ? 1'b0 : 1'b1;
  localparam logic signed [31:0] D_lsv =              1'b1;
  // --- bit vector / bit scalar
  localparam bit [31:0]        T_bv32  = C ? 1'b0 : 1'b1;
  localparam bit [31:0]        D_bv32  =              1'b1;
  localparam bit               T_bt1   = C ? 1'b0 : 1'b1;
  localparam bit               D_bt1   =              1'b1;
  // --- typedef'd int
  typedef int my_int_t;
  localparam my_int_t          T_tdi   = C ? 1'b0 : 1'b1;
  localparam my_int_t          D_tdi   =              1'b1;
  // --- typedef'd vector
  typedef logic [31:0] my_vec_t;
  localparam my_vec_t          T_tdv   = C ? 1'b0 : 1'b1;
  localparam my_vec_t          D_tdv   =              1'b1;
  // --- untyped (implicit)
  localparam                   T_unt   = C ? 1'b0 : 1'b1;
  localparam                   D_unt   =              1'b1;
  // --- ranged untyped
  localparam       [31:0]      T_rgu   = C ? 1'b0 : 1'b1;
  localparam       [31:0]      D_rgu   =              1'b1;
  // --- real (not integral)
  localparam real              T_real  = C ? 1'b0 : 1'b1;
  localparam real              D_real  =              1'b1;
endmodule
