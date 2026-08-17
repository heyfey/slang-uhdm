// r10earl59 VERIFIER arm W4 — the shapes the patch's THREE fences touch at their
// edges: a for-generate body writing a module-level 2-STATE var (the FIRST
// lhsSuppress clause, which the patch deliberately does not reach), a PROGRAM
// scope (an InstanceBody in slang, absent from bindVariable's switch), gen
// nesting at d4, and a CONCAT Lhs (never a ref_obj).
module w4sub (
  input             clk,
  input      [3:0]  din,
  output     [3:0]  o_a,
  output     [3:0]  o_b,
  output int        o_int_fg
);
  wire  [3:0] mn_src;
  logic       me;
  int         m_int_fg;      // module 2-state var written from a FOR-gen body
  logic [3:0] m_var_fg;      // module 4-state var written from a FOR-gen body
  wire  [3:0] mn_fg;         // module net written from a FOR-gen body
  wire  [3:0] mn_d4;         // module net written at d4
  wire  [1:0] mn_c1, mn_c2;  // CONCAT Lhs halves
  assign mn_src = din;
  assign me     = din[0];
  assign o_a    = mn_d4;
  assign o_b    = m_var_fg;

  genvar gi;
  for (gi = 0; gi < 2; gi = gi + 1) begin : g_f
    wire [3:0] lf;
    assign lf       = mn_src;
    assign m_int_fg = lf + 1;             // 2-state var, for-gen, OPERATION
    assign o_int_fg = lf + 2;             // output int port, for-gen, OPERATION
    assign m_var_fg = me ? 4'b0 : lf;     // 4-state var, for-gen, OPERATION
    assign mn_fg    = me ? 4'b0 : lf;     // module NET, for-gen, OPERATION
  end

  if (1) begin : g_1
    if (1) begin : g_2
      if (1) begin : g_3
        if (1) begin : g_4
          wire [3:0] l4;
          assign l4 = mn_src;
          assign mn_d4 = me ? 4'b0 : l4;              // d4, operation
          assign {mn_c1, mn_c2} = l4 | mn_src;        // CONCAT Lhs
        end
      end
    end
  end
endmodule

module a1;
  wire clk; wire [3:0] din, o1, o2; int oi;
  w4sub u_sub (.clk(clk), .din(din), .o_a(o1), .o_b(o2), .o_int_fg(oi));
endmodule
