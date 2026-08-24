// r10v79 adversarial arm 2 — SHAPES: the every-form dimension sweep the brief
// names, with SIZE-form [N] and literal [4] controls beside them.
package pv2;
  parameter int unsigned PP = 8;
  parameter int          PM = 4 * 2;
  localparam int         PL = 3;
endpackage

module sinkv2 #(
  parameter int unsigned N = 6,
  parameter int unsigned A = 5,
  parameter int unsigned B = 3
) (
  input logic clk
);
  localparam int      LM = N * 2;
  localparam int unsigned LA = N + 1;
  localparam int      LL = 6;

  // --- the brief's shape list ---
  logic [7:0] s_p1   [N+1];
  logic [7:0] s_m1   [N-1];
  logic [7:0] s_x2   [N*2];
  logic [7:0] s_d2   [N/2];
  logic [7:0] s_sl   [N<<1];
  logic [7:0] s_cl   [$clog2(N)];
  logic [7:0] s_ab   [A+B];
  logic [7:0] s_abm  [A*B-1];
  logic [7:0] s_par  [(N)];
  logic [7:0] s_par2 [((N+1))];
  logic [7:0] s_cast [int'(N)+1];
  logic [7:0] s_neg  [N-4];
  // --- SIZE-form and literal controls ---
  logic [7:0] s_bare [N];
  logic [7:0] s_lit  [4];
  logic [7:0] s_qual [pv2::PP];
  // --- both-bounds ranged, expression on the LEFT and on the RIGHT ---
  logic [7:0] r_le   [N+1:2];
  logic [7:0] r_re   [2:N+1];
  logic [7:0] r_bb   [N+1:N-4];
  logic [7:0] r_lit  [7:0];
  // --- packed twins of the same shapes ---
  logic [N+1:0]   pk_p1;
  logic [N*2:0]   pk_x2;
  logic [$clog2(N):0] pk_cl;
  logic [N:0]     pk_bare;
  // --- name leaves whose initializer decides the encoding ---
  logic [7:0] n_lm   [LM+1];
  logic [7:0] n_la   [LA+1];
  logic [7:0] n_ll   [LL+1];
  logic [7:0] n_qpm  [pv2::PM+1];
  logic [7:0] n_qpp  [pv2::PP+1];
  // --- two dims, expression in each; and a net twin ---
  logic [7:0] t_two  [N+1][N*2];
  wire  [7:0] t_net  [A*B-1];
  wire  [7:0] t_net2 [N+1];
endmodule

module topv2;
  logic clk;
  sinkv2 #(.N(6),  .A(5), .B(3)) u_a (.clk(clk));
  sinkv2 #(.N(8),  .A(7), .B(2)) u_b (.clk(clk));
  sinkv2 #(.N(10), .A(4), .B(6)) u_c (.clk(clk));
endmodule
