// r10earl56 VERIFIER arm v5 — SHADOWING, TOP-LEVEL gen scopes, INTERFACES,
// NESTED INSTANCES and MULTIPLE ELAB COPIES.  earl47's path lookup rejects a
// same-named localparam from another declaration (`it->second.ps != &sym`), and
// the fence keys on the SYMBOL's parent scope, so a gen scope that SHADOWS a
// module localparam of the same name is the sharpest cross-check: the two refs
// are textually identical and must get different answers.
interface v5_if56 #(parameter int unsigned Depth = 4) (input logic [31:0] din);
  if (Depth != 0) begin : gen_if
    localparam int unsigned IP = 3;
    logic [31:0] i_d0;
    assign i_d0 = {29'b0, din[0 +: IP]};
    if (Depth != 0) begin : gen_ifi
      logic [31:0] i_d1;
      assign i_d1 = {29'b0, din[0 +: IP]};
    end
  end
endinterface

module v5_inner56 #(parameter int unsigned Depth = 4)
                  (input logic [31:0] din, output logic [31:0] o);
  if (Depth != 0) begin : gen_q
    localparam int unsigned QP = 3;
    logic [31:0] q0;
    assign q0 = {29'b0, din[0 +: QP]};
    assign o  = q0;
  end
endmodule

module v5_sub56 #(parameter int unsigned Depth = 4)
                (input logic [31:0] din, output logic [31:0] o);
  localparam int unsigned SH = 5;        // MODULE localparam
  logic [31:0] m_sh;
  assign m_sh = {27'b0, din[0 +: SH]};   // module-scope read (control)

  if (Depth != 0) begin : gen_s
    localparam int unsigned SH = 3;      // SHADOWS the module localparam
    logic [31:0] s_d0;
    assign s_d0 = {29'b0, din[0 +: SH]}; // resolves to the GEN one -> ref_obj?
    if (Depth != 0) begin : gen_si
      logic [31:0] s_d1;
      assign s_d1 = {29'b0, din[0 +: SH]};   // d1 gen one
    end
    // an INSTANCE inside the gen scope, whose own gen scope is d0 for itself
    logic [31:0] io;
    v5_inner56 #(.Depth(Depth)) u_in (.din(din), .o(io));
    assign o = s_d0 ^ io ^ m_sh;
  end
endmodule

module v5_shadow56 (input logic [31:0] din, output logic [31:0] o1,
                    output logic [31:0] o2, output logic [31:0] o3);
  // TOP-LEVEL gen scope: the prefix has ONE fewer dot than in a submodule
  if (1) begin : gen_t
    localparam int unsigned TP = 3;
    logic [31:0] t_d0;
    assign t_d0 = {29'b0, din[0 +: TP]};
    if (1) begin : gen_ti
      logic [31:0] t_d1;
      assign t_d1 = {29'b0, din[0 +: TP]};
    end
    assign o3 = t_d0;
  end
  // TWO instances -> two ELAB copies of the same gen scopes
  v5_sub56 #(.Depth(4)) u_a (.din(din), .o(o1));
  v5_sub56 #(.Depth(2)) u_b (.din(din), .o(o2));
  v5_if56  #(.Depth(4)) u_if (.din(din));
endmodule
