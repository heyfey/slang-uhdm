// r10earl56 VERIFIER arm v4 — THE STATEMENT-KIND / CONTEXT BATTERY.
// genCaLhsParamFold is set by ModuleEmit at TWO ContinuousAssign sites inside
// emitBlock, so the fence's live surface is a gen-scope cont-assign's select
// bounds.  This arm puts a gen-scope-declared param in a select bound in every
// OTHER statement kind that a generate block can hold, plus the shapes that
// reach a ContinuousAssign by a different syntax: net-decl-assign, variable
// declaration initializer, instance port high-conn, an always_comb / always_ff
// / initial read, a function body, and an assertion.  Anything that MOVES here
// and disagrees with golden is a fence over-reach.
module v4_leaf56 (input logic [7:0] i, output logic [7:0] o);
  assign o = i;
endmodule

module v4_sub56 #(parameter int unsigned Depth = 4)
                (input logic clk_i, input logic [31:0] din,
                 output logic [31:0] o);
  if (Depth != 0) begin : gen_v
    localparam int unsigned VP = 3;

    // 1) NET-decl-assign (becomes a cont_assign)
    wire  [31:0] nd  = {29'b0, din[0 +: VP]};
    // 2) VARIABLE decl initializer
    logic [31:0] vd  = {29'b0, din[0 +: VP]};
    // 3) plain cont-assign (the control)
    logic [31:0] ca;
    assign ca = {29'b0, din[0 +: VP]};
    // 4) instance PORT high-conn
    logic [7:0] po;
    v4_leaf56 u_l (.i({5'b0, din[0 +: VP]}), .o(po));
    // 5) always_comb
    logic [31:0] pc;
    always_comb pc = {29'b0, din[0 +: VP]};
    // 6) always_ff
    logic [31:0] pf;
    always_ff @(posedge clk_i) pf <= {29'b0, din[0 +: VP]};
    // 7) initial
    logic [31:0] pi;
    initial pi = {29'b0, din[0 +: VP]};
    // 8) a FUNCTION body inside the gen scope
    function automatic [31:0] f56(input logic [31:0] a);
      return {29'b0, a[0 +: VP]};
    endfunction
    logic [31:0] fr;
    assign fr = f56(din);
    // 9) a select bound inside a CALL ARGUMENT
    logic [31:0] cg;
    assign cg = f56({29'b0, din[0 +: VP]});
    // 10) the cont-assign LHS's OWN select
    logic [31:0] lhs_t;
    assign lhs_t[0 +: VP] = din[2:0];
    assign lhs_t[31:VP]   = 29'b0;
    // 11) a named block inside the gen scope
    logic [31:0] nb;
    always_comb begin : nblk
      nb = {29'b0, din[0 +: VP]};
    end

    // ---- the SAME contexts one gen scope DEEPER (d1) -------------------
    if (Depth != 0) begin : gen_vi
      wire  [31:0] nd1 = {29'b0, din[0 +: VP]};
      logic [31:0] vd1 = {29'b0, din[0 +: VP]};
      logic [31:0] ca1;
      assign ca1 = {29'b0, din[0 +: VP]};
      logic [7:0] po1;
      v4_leaf56 u_l1 (.i({5'b0, din[0 +: VP]}), .o(po1));
      logic [31:0] pc1;
      always_comb pc1 = {29'b0, din[0 +: VP]};
      logic [31:0] lhs_t1;
      assign lhs_t1[0 +: VP] = din[2:0];
      assign lhs_t1[31:VP]   = 29'b0;
      logic [31:0] nb1;
      always_comb begin : nblk1
        nb1 = {29'b0, din[0 +: VP]};
      end
    end

    assign o = nd ^ vd ^ ca ^ {24'b0, po} ^ pc ^ pf ^ pi ^ fr ^ cg ^ lhs_t ^ nb;
  end
endmodule

module v4_contexts56 (input logic clk_i, input logic [31:0] din,
                      output logic [31:0] o1);
  v4_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .o(o1));
endmodule
