package pk79;
  parameter int unsigned PN = 3;
endpackage

typedef logic [7:0] byte79_t;

module leaf79 (input logic a, output logic b);
  assign b = a;
endmodule

module sink79 #(
  parameter int unsigned N = 4,
  parameter int unsigned M = 2
) (
  input  logic clk,
  output logic [7:0] o_plus  [N+1],
  output logic [7:0] o_mul   [N*2],
  output logic [7:0] o_bare  [N],
  output logic [7:0] o_ab    [N+M]
);
  // ---- unpacked var homes, one row per operator ----
  logic [7:0] v_plus  [N+1];
  logic [7:0] v_minus [N-1];
  logic [7:0] v_mul   [N*2];
  logic [7:0] v_div   [N/2];
  logic [7:0] v_shl   [N<<1];
  logic [7:0] v_shr   [N>>1];
  logic [7:0] v_mod   [N%7];
  logic [7:0] v_pow   [2**N];
  logic [7:0] v_and   [N&7];
  logic [7:0] v_or    [N|8];
  logic [7:0] v_clog  [$clog2(N)];
  logic [7:0] v_ab    [N+M];
  logic [7:0] v_am    [N*M];
  logic [7:0] v_paren [(N+1)];
  logic [7:0] v_pkg   [pk79::PN+1];
  logic [7:0] v_bare  [N];
  logic [7:0] v_lit   [7];
  // ---- two dims, expression in each ----
  logic [7:0] v_two   [N+1][N*2];
  // ---- both-bounds ranged unpacked ----
  logic [7:0] v_rng   [N+1:2];
  logic [7:0] v_rngd  [N-1:0];
  // ---- packed twins ----
  logic [N+1:0]  p_plus;
  logic [N*2:0]  p_mul;
  logic [N-1:0]  p_minus;
  logic [N:0]    p_bare;
  // ---- nets ----
  wire  [7:0] w_plus  [N+1];
  wire  [7:0] w_mul   [N*2];
  // ---- typedef'd unpacked array ----
  typedef logic [7:0] ta79_t [N+1];
  ta79_t v_td;
  // ---- instance array ----
  logic ia_a [N+1];
  logic ia_b [N+1];
  leaf79 u_arr [N+1] (.a(ia_a[0]), .b());
  // ---- gen scope ----
  for (genvar gi = 0; gi < 2; gi++) begin : gen_g
    logic [7:0] g_plus [N+1];
    logic [7:0] g_mul  [N*2];
    logic [7:0] g_gv   [gi+2];
    logic [gi+1:0] g_pk;
  end
  assign o_plus = v_plus;
  assign o_mul  = v_mul;
  assign o_bare = v_bare;
  assign o_ab   = v_ab;
endmodule

module top79;
  logic clk;
  logic [7:0] a1 [4], a2 [6], a3 [3], a4 [4];
  logic [7:0] b1 [6], b2 [10], b3 [5], b4 [7];
  logic [7:0] c1 [5], c2 [8], c3 [4], c4 [7];
  sink79 #(.N(3), .M(1)) u_a (.clk(clk), .o_plus(a1), .o_mul(a2), .o_bare(a3), .o_ab(a4));
  sink79 #(.N(5), .M(2)) u_b (.clk(clk), .o_plus(b1), .o_mul(b2), .o_bare(b3), .o_ab(b4));
  sink79 #(.N(4), .M(3)) u_c (.clk(clk), .o_plus(c1), .o_mul(c2), .o_bare(c3), .o_ab(c4));
endmodule
