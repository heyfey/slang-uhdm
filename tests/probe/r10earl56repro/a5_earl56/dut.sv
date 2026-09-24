// r10earl56 a5 — THE REGRESSION THIS PASS CAUGHT AND FIXED, made into an arm.
//
// prim_fifo_sync.sv:127 is `assign storage_rdata = storage[fifo_rptr[
// PTR_WIDTH-2:0]];` inside `gen_depth_gt1`, whose PTR_WIDTH belongs to the
// PARENT gen scope (d1).  The reference sits INSIDE AN OPERATION that is the
// left bound of a part_select that is itself the INDEX of a bit_select, and
// golden's ELAB copy holds a FOLDED CONSTANT there.  The first build of
// § genScopeOwnParamNoSelFold56 fenced it and broke 107 corpus cells.
//
// Every cell here is a reference NESTED IN A BOUND OPERATION, at d0, d1 and d2,
// with and without the enclosing bit_select, plus the bare twins beside them so
// the direct/nested split is visible in one table.
module a5_sub56 #(parameter int unsigned Depth = 4) (
  input  logic        clk_i,
  input  logic [31:0] din,
  input  logic [7:0][31:0] store,
  output logic [31:0] o
);
  localparam int unsigned MW = 3;

  if (Depth != 0) begin : h1
    localparam int unsigned K1 = 3;
    // the corpus's own shape needs the SELECTED signal in the PARENT gen scope
    // and the ARRAY in the inner one (prim_fifo_sync: fifo_rptr lives in
    // gen_normal_fifo, storage in gen_depth_gt1).
    logic [K1:0] ptr;
    assign ptr = din[K1:0];

    if (Depth != 0) begin : h2
      // THE CORPUS SHAPE, verbatim in structure: a part_select whose LEFT bound
      // is an OPERATION over the PARENT scope's localparam, as the INDEX of a
      // bit_select.
      logic [31:0] s_rd;
      assign s_rd = store[din[K1-2:0]];
      // THE CORPUS CELL: array declared HERE, pointer declared one scope OUT.
      logic [Depth-1:0][31:0] stor;
      logic [31:0] s_rd2;
      assign s_rd2 = stor[ptr[K1-2:0]];
      // the same operation bound WITHOUT the enclosing bit_select
      logic [31:0] n_op;
      assign n_op = {29'b0, din[K1-2:0]};
      // an operation bound in an indexed_part_select, d1
      logic [31:0] n_ipsop;
      assign n_ipsop = {29'b0, din[0 +: K1-1]};
      // the BARE twins at d1 (which § genLpUseFoldParentScope47 folds)
      logic [31:0] n_bare, n_bareb;
      assign n_bare  = {29'b0, din[0 +: K1]};
      assign n_bareb = {29'b0, din[K1:1]};

      if (Depth != 0) begin : h3
        // the same operation bound at DISTANCE 2
        logic [31:0] t_op, t_bare;
        assign t_op   = store[din[K1-2:0]];
        assign t_bare = {29'b0, din[0 +: K1]};
      end
    end

    // the same operation bound at DISTANCE 0
    logic [31:0] z_op, z_sel, z_bare;
    assign z_op   = {29'b0, din[K1-2:0]};
    assign z_sel  = store[din[K1-2:0]];
    assign z_bare = {29'b0, din[0 +: K1]};

    // and with the MODULE localparam, nested in an operation
    logic [31:0] m_op, m_sel;
    assign m_op  = {29'b0, din[MW-2:0]};
    assign m_sel = store[din[MW-2:0]];
  end

  assign o = din;
endmodule

module a5_earl56 (input logic clk_i, input logic [31:0] din,
                 input logic [7:0][31:0] store, output logic [31:0] o);
  a5_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .store(store), .o(o));
endmodule
