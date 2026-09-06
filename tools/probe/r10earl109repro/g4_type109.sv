// r10earl109 arm g4 -- THE PARAMETER-TYPE sweep on an ELAB PORT beside the
// ELAB NET of the SAME width, in a STALE-SCOPE module.
//
// g3 showed golden's ELAB PORT bound and golden's ELAB NET bound carry the
// SAME payload in every cell, while OURS agree only for some parameter types.
// This arm names which types those are: the law may only reach a cell whose
// golden answer we can already write, or it moves a cell from one wrong shape
// to another (MOVED-WRONG).
// MEASUREMENT ONLY.  LHS is ALWAYS golden.
module g4_leaf109 (input logic a_i, output logic b_o);
  assign b_o = ~a_i;
endmodule

module g4_kid109 #(
  parameter  int      MaxB109 = 64,
  localparam int      T_int   = 6,
  localparam integer  T_integ = 6,
  localparam longint  T_long  = 6,
  localparam shortint T_short = 6,
  localparam byte     T_byte  = 6,
  localparam bit      T_bit1  = 1'b1,
  localparam logic    T_log1  = 1'b1,
  localparam bit  [7:0]  T_bit8 = 8'd6,
  localparam logic[15:0] T_log16 = 16'd6,
  localparam          T_untl  = 6,                  // untyped, LITERAL init
  localparam          T_untc  = $clog2(MaxB109),    // untyped, COMPUTED init
  localparam int      T_intc  = $clog2(MaxB109)     // int,     COMPUTED init
) (
  input  logic                clk_i,
  input  logic [T_int:0]      p_int_i,
  input  logic [T_integ:0]    p_integ_i,
  input  logic [T_long:0]     p_long_i,
  input  logic [T_short:0]    p_short_i,
  input  logic [T_byte:0]     p_byte_i,
  input  logic [T_bit1:0]     p_bit1_i,
  input  logic [T_log1:0]     p_log1_i,
  input  logic [T_bit8:0]     p_bit8_i,
  input  logic [T_log16:0]    p_log16_i,
  input  logic [T_untl:0]     p_untl_i,
  input  logic [T_untc:0]     p_untc_i,
  input  logic [T_intc:0]     p_intc_i,
  output logic                q_o
);
  // the ELAB NET twins of every one of them
  wire [T_int:0]   n_int;    wire [T_integ:0] n_integ;  wire [T_long:0]  n_long;
  wire [T_short:0] n_short;  wire [T_byte:0]  n_byte;   wire [T_bit1:0]  n_bit1;
  wire [T_log1:0]  n_log1;   wire [T_bit8:0]  n_bit8;   wire [T_log16:0] n_log16;
  wire [T_untl:0]  n_untl;   wire [T_untc:0]  n_untc;   wire [T_intc:0]  n_intc;
  logic lb;
  g4_leaf109 u_leaf (.a_i(clk_i), .b_o(lb));
  assign n_int = p_int_i;      assign n_integ = p_integ_i;
  assign n_long = p_long_i;    assign n_short = p_short_i;
  assign n_byte = p_byte_i;    assign n_bit1 = p_bit1_i;
  assign n_log1 = p_log1_i;    assign n_bit8 = p_bit8_i;
  assign n_log16 = p_log16_i;  assign n_untl = p_untl_i;
  assign n_untc = p_untc_i;    assign n_intc = p_intc_i;
  assign q_o = lb & n_int[0] & n_integ[0] & n_long[0] & n_short[0] &
               n_byte[0] & n_bit1[0] & n_log1[0] & n_bit8[0] & n_log16[0] &
               n_untl[0] & n_untc[0] & n_intc[0];
endmodule

module g4_type109;
  logic clk, q;
  logic [63:0] w;
  g4_kid109 u_t (
    .clk_i(clk), .p_int_i(w), .p_integ_i(w), .p_long_i(w), .p_short_i(w),
    .p_byte_i(w), .p_bit1_i(w), .p_log1_i(w), .p_bit8_i(w), .p_log16_i(w),
    .p_untl_i(w), .p_untc_i(w), .p_intc_i(w), .q_o(q));
endmodule
