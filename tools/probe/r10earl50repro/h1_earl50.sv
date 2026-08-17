// h1: WHICH SELECT SHAPES over a TYPED packed-vector parameter reach Surelog's
// resolver.  This is r10earl49's residue R1: the pre-existing paramNameIsRead
// rule counts a select ANYWHERE in the module's syntax as a read; every cell
// below is read by a select in exactly ONE position, and golden's answer is the
// law.
module h1_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, output logic [31:0] y);
  assign y = S ^ {31'b0, p};
endmodule

module h1_earl50 #(
  parameter int           W   = 32,
  parameter logic [W-1:0] H1  = 'h0,  // bit-sel operand, for-generate CA   (c1.C12)
  parameter logic [W-1:0] H2  = 'h0,  // part-sel operand beside a net      (e1.E7)
  parameter logic [W-1:0] H3  = 'h0,  // bit-sel in a ternary BRANCH, NET cond (jtag_mux)
  parameter logic [W-1:0] H4  = 'h0,  // select in a PROCEDURAL assignment
  parameter logic [W-1:0] H5  = 'h0,  // select in ANOTHER PARAMETER's initializer
  parameter logic [W-1:0] H6  = 'h0,  // select in a GENERATE CONDITION
  parameter logic [W-1:0] H7  = 'h0,  // select in an UNTAKEN generate body  (prim_lfsr)
  parameter logic [W-1:0] H8  = 'h0,  // select in a TAKEN generate body, whole RHS
  parameter logic [W-1:0] H9  = 'h0,  // bit-sel AFTER a bare-net operand
  parameter logic [W-1:0] HA  = 'h0,  // bit-sel operand of a concat, part-sel of a net beside it
  parameter logic [W-1:0] HB  = 'h0,  // bit-sel operand, bare NET operand beside it
  parameter logic [W-1:0] HC  = 'h0,  // select in a PROCEDURAL ternary condition
  parameter logic [W-1:0] HD  = 'h0,  // bit-sel inside a NESTED op, outer walk passes
  parameter logic [W-1:0] HE  = 'h0,  // select in an INSTANCE PARAM OVERRIDE
  parameter logic [W-1:0] HF  = 'h0,  // select in an INSTANCE PORT CONNECTION
  parameter logic [W-1:0] HG  = 'h0   // bit-sel operand beside a bit-sel of a NET
) (
  input  logic         c,
  input  logic [W-1:0] n,
  output logic [W-1:0] o1, o2, o3, o9, oa, ob, od, oe, of, og,
  output logic [W-1:0] r4, rc
);
  // H5 — a select inside another parameter's initializer (LargeHex DReqDepth)
  localparam logic [W-1:0] H5D = {24'b0, H5[7:0]};

  // H1 — bit-select operand of a non-folding op inside a for-generate
  for (genvar k = 0; k < 32; k++) begin : gen_h1
    assign o1[k] = H1[k] | n[k];
  end
  // H2 — a PART-select operand: the pre-scan's Stop exit
  assign o2 = H2[3:0] | n;
  // H3 — bit-select in a ternary BRANCH whose condition is a bare NET
  for (genvar k = 0; k < 32; k++) begin : gen_h3
    assign o3[k] = c ? H3[k] : n[k];
  end
  // H4 — procedural only
  always_comb r4 = H4[3:0] | n;
  // H6 — a generate CONDITION
  if (H6[0]) begin : gen_h6
    wire [W-1:0] t6;
    assign t6 = n;
  end
  // H7 — an UNTAKEN generate branch's body
  if (W > 99) begin : gen_h7
    wire [W-1:0] t7;
    assign t7 = H7[W-1:0];
  end
  // H8 — a TAKEN generate branch's body, part-select IS the whole RHS
  if (W > 0) begin : gen_h8
    wire [W-1:0] t8;
    assign t8 = H8[W-1:0];
  end
  // H9 — a bare NET operand comes FIRST and stops the walk
  assign o9 = n & {{(W-1){1'b0}}, H9[0]};
  // HA — concat of a bit-select and a NET PART-select
  assign oa = {HA[0], n[W-2:0]};
  // HB — bit-select operand with a bare NET operand beside it
  assign ob = HB[0] & n;
  // HC — a PROCEDURAL ternary condition
  always_comb rc = HC[0] ? n : '0;
  // HD — bit-select inside a NESTED operation; nothing stops the outer walk
  assign od = (HD[0] | 1'b0) & 32'h1;
  // HE — read only as an instance PARAMETER OVERRIDE, through a select
  h1_sub #(.S({24'b0, HE[7:0]})) u_he (.p(c), .y(oe));
  // HF — read only in an instance PORT CONNECTION, through a select
  h1_sub #(.S(32'h0)) u_hf (.p(HF[0]), .y(of));
  // HG — bit-select operand beside a bit-select of a NET
  assign og = {31'b0, HG[0] & n[0]};
endmodule
