// v11u74 v1 — LAW B, THE NEAREST-ENCLOSING CLAIM.  The patch walks OUT from
// the writing scope and takes the FIRST namesake it finds.  Golden's own
// mechanism may instead be a flat instance-level name bind, in which case the
// module-body object wins even when an ancestor generate scope has one.
// Every Rhs is the same literal so the only thing that can vary is vpiActual.
module dut (output logic [31:0] o);
  logic [31:0] x;             // module-body namesake
  logic [31:0] y;             // module-body namesake, TWO hops up
  logic [31:0] z;             // module-body namesake, ancestor has none
  for (genvar i = 0; i < 2; i = i + 1) begin : ga
    logic [31:0] x;           // ANCESTOR gen-scope namesake of x
    assign x = 32'd1;
    if (i == 1) begin : gin
      logic [31:0] x;         // target here; namesake in ga AND in the body
      logic [31:0] y;         // target here; namesake only in the body
      logic [31:0] z;         // target here; namesake only in the body
      assign x = 32'd2;
      assign y = 32'd3;
      assign z = 32'd4;
    end
  end
  assign o = ga[0].x ^ ga[1].gin.x ^ ga[1].gin.y ^ ga[1].gin.z ^ x ^ y ^ z;
endmodule
