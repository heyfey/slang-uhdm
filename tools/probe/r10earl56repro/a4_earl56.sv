// r10earl56 a4 — THE REGRESSION HUNT.  Every shape that could make the fence
// turn a PRISTINE-RIGHT constant into a wrong ref_obj, i.e. a d1 cell that
// § genLpUseFoldParentScope47 REFUSES and the fenced arm used to fold:
//
//   * a gen localparam with a NON-LITERAL initializer (prim_fifo_sync's own
//     `$clog2(Depth) + ~|$clog2(Depth)` shape), read at d0 AND at d1 — the
//     registration those two ModuleEmit sites do is what the one-hop law needs,
//     and a shape they skip would leave the d1 cell with nobody to fold it;
//   * a d1 read whose dropped name component is a NAMED BLOCK / FUNCTION rather
//     than a generate child (earl47's F1 gate, which REFUSES);
//   * a d1 read from inside a for-generate body (the loop fence);
//   * the MODULE localparam in the LHS-select and call-argument positions a3
//     found golden splitting on.
module a4_sub56 #(parameter int unsigned Depth = 4) (
  input  logic        clk_i,
  input  logic [31:0] din,
  output logic [31:0] o
);
  localparam int unsigned MW = 3;
  function automatic [31:0] f56(input [31:0] a); return a; endfunction

  if (Depth != 0) begin : g1
    // the prim_fifo_sync shape, verbatim in spirit
    localparam int unsigned PW = $clog2(Depth) + ~|$clog2(Depth);
    localparam int unsigned PW1 = PW + 1;

    logic [31:0] z0_ipsw, z0_ipsb, z0_ps, z0_bit;
    assign z0_ipsw = {29'b0, din[0 +: PW]};      // d0, non-literal init
    assign z0_ipsb = {28'b0, din[PW +: 4]};
    assign z0_ps   = {29'b0, din[PW:1]};
    assign z0_bit  = {31'b0, din[PW]};
    logic [31:0] y0_ipsw;
    assign y0_ipsw = {29'b0, din[0 +: PW1]};     // d0, init reads a sibling lp

    if (Depth != 0) begin : g2
      logic [31:0] z1_ipsw, z1_ipsb, z1_ps, z1_bit;
      assign z1_ipsw = {29'b0, din[0 +: PW]};    // d1, non-literal init
      assign z1_ipsb = {28'b0, din[PW +: 4]};
      assign z1_ps   = {29'b0, din[PW:1]};
      assign z1_bit  = {31'b0, din[PW]};
    end

    // a d1 read from inside a FOR-generate body
    for (genvar gi = 0; gi < 2; gi++) begin : g3
      logic [31:0] q1_ipsw;
      assign q1_ipsw = {29'b0, din[0 +: PW]};
    end

    // the MODULE localparam in the two positions a3 split on
    logic [31:0] mlhs, marg;
    assign mlhs[0 +: MW] = din[2:0];
    assign mlhs[31:MW]   = '0;
    assign marg = f56({29'b0, din[0 +: MW]});

    // a d0 read whose select sits inside a PROCEDURAL named block
    logic [31:0] nb_o;
    always_comb begin : nb
      nb_o = {29'b0, din[0 +: PW]};
    end
  end

  assign o = din;
endmodule

module a4_earl56 (input logic clk_i, input logic [31:0] din,
                 output logic [31:0] o);
  a4_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .o(o));
endmodule
