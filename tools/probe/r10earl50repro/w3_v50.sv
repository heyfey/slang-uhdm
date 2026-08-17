// r10earl50 VERIFIER arm w3 — OWNER edges.  `paramCaFoldRead` harvests a BARE
// NAME into a per-InstanceBody set and answers `names.count(ps.name)`, so two
// parameters of the SAME NAME in the same body are conflated.  Before this pass
// the scan saw only MODULE-BODY cont-assigns, where no shadowing is possible;
// § selectReadNeedsReduce50 walks the instantiated GENERATE BLOCKS too, and a
// generate block MAY declare a localparam that shadows a module parameter.
package w3p;
  parameter logic [31:0] PK = 32'h11;
  parameter logic [31:0] SG = 32'h22;
endpackage

module w3_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, output logic y);
  assign y = (^S) & p;
endmodule

module w3_v50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] SH = 'h0,  // READ NOWHERE; a gen-block localparam SH is
                                     // read by a SELECT in a gen-block cont-assign
  parameter logic [W-1:0] SB = 'h0,  // READ NOWHERE; a gen-block localparam SB is
                                     // read by a BARE NAME in a gen-block cont-assign
  parameter logic [W-1:0] PK = 'h0,  // READ NOWHERE; the PACKAGE param w3p::PK is
                                     // read by a whole-folding module-body assign
  parameter logic [W-1:0] SG = 'h0,  // READ NOWHERE; the PACKAGE param w3p::SG is
                                     // read by a SELECT in a gen-block cont-assign
  parameter logic [W-1:0] UH = 'h0,  // CONTROL: read by a select in a gen-block CA
  parameter logic [W-1:0] VH = 'h0   // CONTROL: read by a select in a module-body CA
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] os, ob, op, og, ou, ov
);
  if (W > 0) begin : gen_sh
    localparam logic [W-1:0] SH = 'h5;
    assign os = SH[0] | n[0];
  end
  if (W > 0) begin : gen_sb
    localparam logic [W-1:0] SB = 'h5;
    assign ob = SB | n;
  end
  // PK — the PACKAGE parameter of the same name, in a whole-folding module assign
  assign op = w3p::PK + 32'h1;
  // SG — the PACKAGE parameter of the same name, selected inside a gen block
  if (W > 0) begin : gen_sg
    assign og = w3p::SG[0] | n[0];
  end
  // UH / VH — the same read shapes on parameters nothing shadows
  if (W > 0) begin : gen_uh
    assign ou = UH[0] | n[0];
  end
  assign ov = VH[0] | n[0];
endmodule
