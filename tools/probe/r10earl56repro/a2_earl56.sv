// r10earl56 a2 — the AXES a1 did not sweep: DISTANCE 2, FOR-GENERATE bodies,
// PROCEDURAL reads, a BARE part_select bound, an OPERATION in an ips bound, a
// GENVAR, a gen-scope `parameter` (not `localparam`), and a d0 localparam of a
// NESTED gen scope.  a1 established the d0 / d1 / dM / dP split for the four
// bare-bound positions; every cell here is a place the law could over- or
// under-fire.
module a2_sub56 #(parameter int unsigned Depth = 4) (
  input  logic        clk_i,
  input  logic [31:0] din,
  output logic [31:0] o
);
  localparam int unsigned MW = 3;

  if (Depth != 0) begin : g1
    localparam int unsigned L1 = 3;          // d0 for g1, d1 for g2, d2 for g3
    parameter  int unsigned P1 = 3;          // gen-scope `parameter` keyword

    // ---- d0, the positions a1 did not have -----------------------------
    logic [31:0] b_psbare, b_ipswop, b_ipsbop, b_pkw;
    assign b_psbare = {28'b0, din[L1:1]};        // BARE part_select bounds, d0
    assign b_ipswop = {29'b0, din[0 +: L1-1]};   // ips WIDTH is an OPERATION
    assign b_ipsbop = {28'b0, din[L1-1 +: 4]};   // ips BASE  is an OPERATION
    assign b_pkw    = {29'b0, din[0 +: P1]};     // gen-scope `parameter`

    // ---- d0 PROCEDURAL --------------------------------------------------
    logic [31:0] pc_ipsw, pc_ipsb, pc_bit;
    always_comb pc_ipsw = {29'b0, din[0 +: L1]};
    always_comb pc_ipsb = {28'b0, din[L1 +: 4]};
    always_comb pc_bit  = {31'b0, din[L1]};
    logic [31:0] pf_ipsw;
    always_ff @(posedge clk_i) pf_ipsw <= {29'b0, din[0 +: L1]};

    // ---- d1 and d2 ------------------------------------------------------
    if (Depth != 0) begin : g2
      localparam int unsigned L2 = 3;        // d0 for g2
      logic [31:0] d1_ipsw, d1_bit, own_ipsw, own_bit;
      assign d1_ipsw  = {29'b0, din[0 +: L1]};   // d1  (one hop up)
      assign d1_bit   = {31'b0, din[L1]};        // d1, bit_select index
      assign own_ipsw = {29'b0, din[0 +: L2]};   // d0 of a NESTED gen scope
      assign own_bit  = {31'b0, din[L2]};        // d0 nested, bit index
      if (Depth != 0) begin : g3
        logic [31:0] d2_ipsw, d2_bit, d1b_ipsw;
        assign d2_ipsw  = {29'b0, din[0 +: L1]}; // d2  (TWO hops up)
        assign d2_bit   = {31'b0, din[L1]};      // d2, bit index
        assign d1b_ipsw = {29'b0, din[0 +: L2]}; // d1 from the inner scope
      end
    end

    // ---- a FOR-GENERATE body, d0 and dOuter -----------------------------
    for (genvar gi = 0; gi < 2; gi++) begin : g4
      localparam int unsigned L4 = 3;        // d0 inside a LOOP body
      logic [31:0] f_ipsw, f_bit, fo_ipsw, fg_ipsw;
      assign f_ipsw  = {29'b0, din[0 +: L4]};    // d0, loop body
      assign f_bit   = {31'b0, din[L4]};
      assign fo_ipsw = {29'b0, din[0 +: L1]};    // d1 out of a loop body
      assign fg_ipsw = {29'b0, din[gi +: 4]};    // a GENVAR base
    end
  end

  assign o = din;
endmodule

module a2_earl56 (input logic clk_i, input logic [31:0] din,
                 output logic [31:0] o);
  a2_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .o(o));
endmodule
