// r10earl93 g5 -- THE SHAPE GRID: a cast NESTED in another cast, a cast inside
// an operation, a cast over an operation, a cast over a concat / replication /
// a stream / a call, and the written-tick fence.  MEASUREMENT ONLY.
module g5;
  localparam int unsigned PW = 64;
  localparam logic [63:0] SRCA = 64'hFFFFFFFFFFFFFFFF;
  function automatic logic [63:0] f64(); return 64'hFFFFFFFFFFFFFFFF; endfunction
  // nested casts
  localparam s_n_6464 = 64'(64'(64'hFFFFFFFFFFFFFFFF));
  localparam s_n_9664 = 96'(64'(64'hFFFFFFFFFFFFFFFF));
  localparam s_n_6496 = 64'(96'(64'hFFFFFFFFFFFFFFFF));
  localparam s_n_3264 = 32'(64'(64'hFFFFFFFFFFFFFFFF));
  localparam s_n_6432 = 64'(32'(64'hFFFFFFFFFFFFFFFF));
  // the cast INSIDE an operation
  localparam s_in_add = 64'(64'd1) + 64'd1;
  localparam s_in_or  = 64'(64'hFFFFFFFFFFFFFFFF) | 64'd1;
  localparam s_in_tern= (1'b1) ? 64'(64'd1) : 64'd0;
  localparam s_in_cat = {64'(64'd1)};
  // the cast OVER an operation
  localparam s_ov_add = 64'(64'd1 + 64'd1);
  localparam s_ov_cat = 64'({32'hFFFFFFFF, 32'hFFFFFFFF});
  localparam s_ov_rep = 64'({2{32'hFFFFFFFF}});
  typedef logic [63:0] s5_t;
  wire [31:0] a32, b32;
  wire [63:0] s_ov_str; assign s_ov_str = s5_t'({ << 8 {a32, b32}});
  localparam s_ov_cal = 64'(f64());
  // a cast over a parameter read and over a select
  localparam s_ov_par = 64'(SRCA);
  localparam s_ov_sel = 64'(SRCA[31:0]);
  localparam s_ov_bit = 64'(SRCA[0]);
  // an IMPLICIT conversion (no written tick) must never mask
  localparam logic [63:0] s_imp_w = 64'hFFFFFFFFFFFFFFFF;
  localparam logic [95:0] s_imp_x = 64'hFFFFFFFFFFFFFFFF;
  localparam logic [63:0] s_imp_y = SRCA;
endmodule
