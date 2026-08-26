// r10earl95 arm g5 -- THE HOP IS COUNTED IN THE **EMITTED** TREE, NOT THE
// SYNTAX TREE.  `pushGenBlk9` splices a generate level out of the model in two
// documented cases (§ genElseArmCollapse48's ELSE arm whose first item is a
// named if-generate, and `genHoists9`), and Surelog's elaborator drops the same
// level.  Each row below is TWO generate blocks in slang and ONE `gen_scope` in
// golden -- so a module parameter read there is ONE hop and MUST fold.
// The `c_keep` rows are the uncollapsed twin, TWO hops, and MUST NOT fold.
// MEASUREMENT ONLY.
module h95 #(
  parameter int unsigned W = 4
) (
  input  logic [7:0]   e_i,
  output logic [W-1:0] o_o
);
  logic [63:0] m_net;
  logic [63:0] q [0:7];

  // COLLAPSING: the ELSE arm's first item is a named if-generate, so golden
  // drops the arm level and `c_in` is the only generate scope.
  if (W == 4) begin : c_four
    if (1) begin : c_keep
      assign q[0] = m_net[W-1:0];     // TWO emitted hops -> ref_obj
      assign q[1] = {W{e_i[0]}};      // TWO emitted hops -> ref_obj
    end
  end else begin : c_other
    if (1) begin : c_in
      assign q[2] = m_net[W-1:0];     // ONE emitted hop  -> FOLD
      assign q[3] = {W{e_i[0]}};      // ONE emitted hop  -> FOLD
    end
  end

  // A FLAT control at one hop, and its nested twin at two.
  if (1) begin : f_top
    assign q[4] = m_net[W-1:0];       // ONE hop -> FOLD
    if (1) begin : f_in
      assign q[5] = m_net[W-1:0];     // TWO hops -> ref_obj
    end
  end

  assign o_o = q[0][W-1:0] ^ q[2][W-1:0] ^ q[4][W-1:0] ^ q[5][W-1:0];
endmodule

module toph95;
  logic [7:0] e;
  logic [3:0] o4;
  logic [7:0] o8;
  logic [5:0] o6;
  h95 #(.W(4)) u4 (.e_i(e), .o_o(o4));
  h95 #(.W(8)) u8 (.e_i(e), .o_o(o8));
  h95 #(.W(6)) u6 (.e_i(e), .o_o(o6));
endmodule
