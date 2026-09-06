// r10uvm168repro/g168_d_notmove.sv — MEASUREMENT ONLY.
// ARM D: the NEGATIVE CONTROLS.  Every folded package/module parameter shape
// this pass must NOT touch, written in the SAME homes the law fires in, so an
// over-wide gate shows up here as an AWAY cell rather than as a corpus
// regression.  Nothing in this file reaches an enum member.
package quarry_pkg;

  // plain integer folds of every base and sign
  parameter int      kd_dec     = 12;
  parameter int      kd_neg     = -12;
  parameter          kd_bare    = 12;
  parameter logic [7:0] kd_bin  = 8'b1010_0101;
  parameter logic [7:0] kd_hex  = 8'hC3;
  parameter logic [7:0] kd_oct  = 8'o17;
  parameter logic [7:0] kd_bdec = 8'd200;
  parameter logic [7:0] kd_unsz = 'h2A;
  parameter real     kd_real    = 2.5;
  parameter string   kd_str     = "quarry";

  // arithmetic (the ExprEval sign rules this pass must leave alone)
  parameter int      kd_add     = 5 + 6;
  parameter int      kd_sub     = 15 - 4;
  parameter int      kd_mul     = 3 * 4;
  parameter int      kd_div     = 24 / 2;
  parameter int      kd_mod     = 25 % 14;
  parameter int      kd_shl     = 3 << 2;
  parameter int      kd_pow     = 2 ** 3;
  parameter bit      kd_cmp     = (5 > 3);

  // parameter hops that never reach an enum
  parameter int      kd_hop1    = kd_dec;
  parameter int      kd_hop2    = kd_hop1;
  parameter logic [7:0] kd_hophex = kd_hex;
  parameter logic [7:0] kd_hopoct = kd_oct;

  // STRUCT/typedef'd non-enum types
  typedef logic [3:0] nibble_t;
  parameter nibble_t kd_nib     = 4'd9;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } pair_t;
  parameter pair_t   kd_pair    = '{a: 4'd1, b: 4'd2};

  // a CAST and a concat/replication
  parameter int      kd_cast    = int'(7);
  parameter logic [7:0] kd_cat  = {4'b1100, 4'b0011};
  parameter logic [7:0] kd_repl = {8{1'b1}};

  // a string/real hop
  parameter string   kd_hopstr  = kd_str;
  parameter real     kd_hopreal = kd_real;

endpackage

module quarry_mod;
  import quarry_pkg::*;
  parameter int      kd_m_dec   = 12;
  localparam int     kd_m_hop   = kd_dec;
  localparam logic [7:0] kd_m_hophex = kd_hex;
  localparam logic [7:0] kd_m_hopoct = kd_oct;
  localparam int     kd_m_add   = kd_dec + 1;
endmodule
