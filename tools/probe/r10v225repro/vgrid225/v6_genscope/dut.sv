// r10v225 arm v6_genscope — containers declared BELOW the interface body: in a
// generate block, in a named block, and in a modport-carrying interface.  The
// law must reach exactly the nets golden's `writeNets` walks and no more.
typedef logic [7:0] tvg_t;

interface if225v_gen();
  parameter int G = 1;
  tvg_t g_top_fix [1:0];
  tvg_t g_top_dyn [];
  generate
    if (G == 1) begin : bg
      tvg_t g_in_fix [1:0];
      tvg_t g_in_dyn [];
      tvg_t g_in_as  [string];
    end
  endgenerate
  for (genvar i = 0; i < 2; i++) begin : bl
    tvg_t g_lp_fix [1:0];
    tvg_t g_lp_q   [$];
  end
endinterface

interface if225v_mp();
  tvg_t p_fix [1:0];
  tvg_t p_dyn [];
  tvg_t p_as  [string];
  logic clk;
  modport mst (input clk, output p_fix);
  modport slv (input clk);
endinterface

module top225v_gen(); endmodule
