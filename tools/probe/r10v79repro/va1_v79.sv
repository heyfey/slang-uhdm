// r10v79 adversarial arm 1 — HOMES the implementer's grids do not cover:
// gen-if, nested gen, interface, program, non-ANSI io_decl, instance arrays.
package pv1;
  parameter int unsigned PQ = 6;
endpackage

interface iface1 #(parameter int unsigned N = 4) (input logic clk);
  logic [7:0] if_plus [N+1];
  logic [7:0] if_mul  [N*2];
  logic [7:0] if_bare [N];
  logic [7:0] if_clog [$clog2(N)];
  wire  [7:0] if_net  [N-1];
endinterface

module sinkv1 #(
  parameter int unsigned N = 4,
  parameter int unsigned M = 2
) (clk, o_np, o_bare);
  // NON-ANSI io_decl with expression dims
  input  logic clk;
  output logic [7:0] o_np   [N+1];
  output logic [7:0] o_bare [N];

  logic [7:0] m_plus [N+1];
  logic [7:0] m_sub4 [N-4];
  logic [7:0] m_amb1 [N*M-1];
  logic [7:0] m_pq   [pv1::PQ*2];

  if (1) begin : gen_if_t
    logic [7:0] gi_plus [N+1];
    logic [7:0] gi_mul  [N*2];
    logic [7:0] gi_clog [$clog2(N)];
    wire  [7:0] gi_net  [N-1];
  end
  else begin : gen_if_f
    logic [7:0] gf_plus [N+1];
  end

  for (genvar ga = 0; ga < 2; ga++) begin : gen_o
    for (genvar gb = 0; gb < 2; gb++) begin : gen_i
      logic [7:0] gn_plus [N+1];
      logic [7:0] gn_gv   [ga+gb+2];
      logic [7:0] gn_gmul [ga*2+1];
      logic [7:0] gn_mul  [N*2];
    end
  end

  iface1 #(.N(N)) u_if (.clk(clk));
  assign o_np   = m_plus;
  assign o_bare = '{default:'0};
endmodule

program prog1 #(parameter int unsigned N = 4);
  logic [7:0] pr_plus [N+1];
  logic [7:0] pr_mul  [N*2];
  initial begin end
endprogram

module topv1;
  logic clk;
  logic [7:0] x1 [7], x2 [6];
  logic [7:0] y1 [9], y2 [8];
  logic [7:0] z1 [11], z2 [10];
  sinkv1 #(.N(6), .M(2)) u_a (.clk(clk), .o_np(x1), .o_bare(x2));
  sinkv1 #(.N(8), .M(3)) u_b (.clk(clk), .o_np(y1), .o_bare(y2));
  sinkv1 #(.N(10), .M(4)) u_c (.clk(clk), .o_np(z1), .o_bare(z2));
  prog1 #(.N(5)) u_p ();
endmodule
