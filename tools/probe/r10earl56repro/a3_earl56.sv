// r10earl56 a3 — THE BOUNDARY.  Every position the fenced arm ALSO serves, and
// every neighbouring arm the fence could reach by accident.  a1 and a2 said
// what golden does at d0/d1/d2 for the four bare-bound positions; this arm asks
// whether the fence changes anything ELSE: a var_select with a TRAILING select
// (§ genLpUseFoldParentScope47's call sites 1-2, which never set inPsBound), a
// bare non-bound gen-CA read (the `!inPsBound` twin arm), a bit_select of an
// ARRAY, a select bound inside a FUNCTION CALL argument, a select on the
// cont-assign LHS, and the same shapes for a MODULE localparam (which must keep
// folding).
module a3_sub56 #(parameter int unsigned Depth = 4) (
  input  logic        clk_i,
  input  logic [31:0] din,
  input  logic [3:0][31:0] arr,
  output logic [31:0] o
);
  localparam int unsigned MW = 3;
  function automatic [31:0] f56(input [31:0] a); return a; endfunction

  if (Depth != 0) begin : g1
    localparam int unsigned L1 = 3;

    // ---- var_select with a TRAILING select: call sites 1-2 of the one-hop
    // law, which do NOT set inPsBound, so the fence must not reach them ----
    logic [31:0] v_ips, v_ps, v_bit;
    assign v_ips = {29'b0, arr[1][0 +: L1]};
    assign v_ps  = {29'b0, arr[1][L1:1]};
    assign v_bit = {31'b0, arr[1][L1]};

    // ---- the BARE (non-bound) gen-CA read: the `!inPsBound` twin arm -------
    logic [31:0] r_bare, r_op;
    assign r_bare = L1;
    assign r_op   = L1 + din;

    // ---- a bit_select of an unpacked/packed ARRAY by a d0 param -----------
    logic [31:0] a_bit;
    assign a_bit = arr[L1];

    // ---- a select bound inside a FUNCTION-CALL argument -------------------
    logic [31:0] c_arg;
    assign c_arg = f56({29'b0, din[0 +: L1]});

    // ---- a select on the cont-assign LHS ---------------------------------
    logic [31:0] lhs_t;
    assign lhs_t[0 +: L1] = din[2:0];
    assign lhs_t[31:L1]   = '0;

    // ---- the SAME shapes with the MODULE localparam (must keep folding) ---
    logic [31:0] mv_ips, mr_bare, mc_arg, ml_t;
    assign mv_ips  = {29'b0, arr[1][0 +: MW]};
    assign mr_bare = MW;
    assign mc_arg  = f56({29'b0, din[0 +: MW]});
    assign ml_t    = {29'b0, din[0 +: MW]};
  end

  assign o = din;
endmodule

module a3_earl56 (input logic clk_i, input logic [31:0] din,
                 input logic [3:0][31:0] arr, output logic [31:0] o);
  a3_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .arr(arr), .o(o));
endmodule
