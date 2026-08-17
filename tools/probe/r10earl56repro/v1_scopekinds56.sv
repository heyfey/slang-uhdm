// r10earl56 VERIFIER arm v1 — THE SCOPE-SHAPE / NAMING BATTERY.
// § genScopeOwnParamNoSelFold56 abstains for a param whose IMMEDIATE parent
// scope is a GenerateBlock/GenerateBlockArray.  At d1 the fence is only SAFE
// because § genLpUseFoldParentScope47 folds first.  earl47 REFUSES when its
// okChild47 name-hop test fails or the localparam is not in genLpFoldByPath.
// This arm hunts d1 shapes where earl47 can refuse: UNNAMED gen blocks (both
// as the declaring scope and as the hop), case-generate blocks, an explicit
// generate/endgenerate region, and three-deep chains.
package pkv56;
  parameter int PKV = 3;
endpackage

module v1_leaf56 (input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule

module v1_sub56 #(parameter int unsigned Depth = 4)
                (input logic [31:0] din, output logic [31:0] o);
  logic [31:0] acc;

  // ---- A: NAMED declaring scope, UNNAMED hop (d1 through an unnamed block)
  if (Depth != 0) begin : gen_a
    localparam int unsigned PA = 3;
    logic [31:0] a_d0w, a_d0l;
    assign a_d0w = {29'b0, din[0 +: PA]};      // d0 ips WIDTH
    assign a_d0l = {29'b0, din[PA:1]};         // d0 psel LEFT (bare)
    if (Depth != 0) begin                       // UNNAMED child
      logic [31:0] a_d1w, a_d1l;
      assign a_d1w = {29'b0, din[0 +: PA]};    // d1 ips WIDTH via unnamed hop
      assign a_d1l = {29'b0, din[PA:1]};       // d1 psel LEFT via unnamed hop
    end
  end

  // ---- B: UNNAMED declaring scope, NAMED hop
  if (Depth != 0) begin                         // UNNAMED
    localparam int unsigned PB = 3;
    logic [31:0] b_d0w;
    assign b_d0w = {29'b0, din[0 +: PB]};      // d0 in an unnamed gen scope
    if (Depth != 0) begin : gen_bi
      logic [31:0] b_d1w, b_d1l;
      assign b_d1w = {29'b0, din[0 +: PB]};    // d1 from an unnamed declarer
      assign b_d1l = {29'b0, din[PB:1]};
    end
  end

  // ---- C: CASE-generate blocks
  case (Depth)
    4: begin : gen_c
      localparam int unsigned PC = 3;
      logic [31:0] c_d0w;
      assign c_d0w = {29'b0, din[0 +: PC]};    // d0 in a case-generate block
      case (Depth)
        4: begin : gen_ci
          logic [31:0] c_d1w;
          assign c_d1w = {29'b0, din[0 +: PC]}; // d1 across two case-gens
        end
        default: begin : gen_cd
          logic [31:0] c_dd;
          assign c_dd = din;
        end
      endcase
    end
    default: begin : gen_cz
      logic [31:0] c_z;
      assign c_z = din;
    end
  endcase

  // ---- D: explicit generate/endgenerate region, THREE deep (d1 and d2)
  generate
    if (Depth != 0) begin : gen_d1
      localparam int unsigned PD = 3;
      logic [31:0] d_d0w;
      assign d_d0w = {29'b0, din[0 +: PD]};    // d0
      if (Depth != 0) begin : gen_d2
        logic [31:0] d_d1w;
        assign d_d1w = {29'b0, din[0 +: PD]};  // d1
        if (Depth != 0) begin : gen_d3
          logic [31:0] d_d2w, d_d2l;
          assign d_d2w = {29'b0, din[0 +: PD]}; // d2  (golden: ref_obj)
          assign d_d2l = {29'b0, din[PD:1]};
        end
      end
    end
  endgenerate

  // ---- E: an ELSE-branch block, and a d1 whose declarer is the ELSE block
  if (Depth == 0) begin : gen_e_t
    logic [31:0] e_t;
    assign e_t = din;
  end else begin : gen_e
    localparam int unsigned PE = 3;
    logic [31:0] e_d0w;
    assign e_d0w = {29'b0, din[0 +: PE]};
    if (Depth != 0) begin : gen_ei
      logic [31:0] e_d1w;
      assign e_d1w = {29'b0, din[0 +: PE]};
    end
  end

  assign o = din ^ acc;
  assign acc = {29'b0, din[0 +: Depth]} ^ {29'b0, din[0 +: pkv56::PKV]};
endmodule

module v1_scopekinds56 (input logic [31:0] din, output logic [31:0] o1);
  v1_sub56 #(.Depth(4)) u_s (.din(din), .o(o1));
endmodule
