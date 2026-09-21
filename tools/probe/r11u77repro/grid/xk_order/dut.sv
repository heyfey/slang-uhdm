// r11v75 xk — LAW A AND DECLARATION ORDER.  `genScopeNets` is filled by
// `emitGenScopes`' own member loop; a nested block emitted BEFORE the
// enclosing scope's net is minted would find nothing.  Row `pre` declares the
// net first (v9_hops' order), row `post` declares it last.  Also asks the NET
// KINDS pass 73's grid did not: `tri`, `wand`, `supply0`.
module dut (input logic [31:0] a_i, output logic [31:0] o);
  if (1) begin : P1
    wire [31:0] pre_ns;  assign pre_ns = a_i;
    if (1) begin : P2
      logic [31:0] pre_ns;   assign pre_ns  = 32'd1;
      logic [31:0] post_ns;  assign post_ns = 32'd2;
      logic [31:0] tri_ns;   assign tri_ns  = 32'd3;
      logic [31:0] wand_ns;  assign wand_ns = 32'd4;
      logic [31:0] sup_ns;   assign sup_ns  = 32'd5;
    end
    tri  [31:0] tri_ns;   assign tri_ns  = a_i;
    wand [31:0] wand_ns;  assign wand_ns = a_i;
    supply0 [31:0] sup_ns;
    wire [31:0] post_ns;  assign post_ns = a_i;
  end
  assign o = P1.P2.pre_ns ^ P1.P2.post_ns ^ P1.P2.tri_ns ^ P1.P2.wand_ns
           ^ P1.P2.sup_ns;
endmodule
