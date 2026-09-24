// r10v105 v4 — THE HOMES the law must NOT reach, in a CHILD instance (the only
// place the new window `loopPlainNew105` is armed).  Every read here must be
// byte-identical between the two binaries.
module v4_leaf105 #(parameter int P = 5) (input logic [31:0] sig, output logic [63:0] z);
  localparam int MOD = 6;
  logic [63:0] m0;
  assign m0 = MOD ^ sig;                       // MODULE-scope CA: no gen scope

  if (1) begin : gen_if_top                     // a TOP-LEVEL gen-IF, not a loop
    logic [63:0] f0;
    assign f0 = MOD ^ sig;
  end

  for (genvar i = 0; i < 2; i++) begin : gen_l
    localparam int LOC = 7;                     // a GEN-LOCAL localparam
    logic [63:0] a0, a1, a2;
    assign a0 = LOC ^ sig;                      // gen-local: must keep the ref
    assign a1 = i ^ sig;                        // a GENVAR: must keep the ref
    assign a2 = MOD ^ sig;                      // the law's own window
    if (1) begin : gen_if_in                    // a gen-IF NESTED in the loop
      logic [63:0] b0;
      assign b0 = MOD ^ sig;
    end
    for (genvar j = 0; j < 2; j++) begin : gen_n  // a loop NESTED in the loop
      logic [63:0] c0;
      assign c0 = MOD ^ sig;
    end
  end

  if (1) begin : gen_if_out                      // a loop NESTED in a gen-IF
    for (genvar k = 0; k < 2; k++) begin : gen_k
      logic [63:0] d0;
      assign d0 = MOD ^ sig;
    end
  end

  always_comb begin : proc                       // PROCEDURAL, not a CA
    // no assignment target needed for the read to be emitted
  end
  assign z = 64'b0;
endmodule

module v4_home105 (input logic [31:0] sig, output logic [63:0] z);
  logic [63:0] zc;
  v4_leaf105 #(.P(5)) u_leaf (.sig(sig), .z(zc));
  assign z = zc;
endmodule
