// r10v78 arm v5 — INSTANCE ACTUALS carrying replications (the
// ReplicationPassedToInstance blocker) as a MEASURED FENCE, plus every shape
// the law REFUSES, plus non-replication controls.
module v5leaf #(parameter int W = 6) (input logic [W-1:0] a, input logic [3:0] b,
                                      output logic [3:0] y);
  assign y = b;
endmodule
module v5;
  localparam int TW = 6;
  localparam int Z  = 0;
  logic [3:0] ya, yb, yc;
  logic [5:0] r_x, r_z, r_cat, r_zc, r_lit, r_ctl, r_nest, r_cat2;
  logic       s1;
  // module-body actual controls
  v5leaf #(.W(6)) m_u0 (.a({TW{1'b1}}), .b({4{1'b1}}), .y(ya));
  if (TW > 0) begin : g5
    // the FENCE: a replication passed as an instance ACTUAL from a gen scope
    v5leaf #(.W(6)) g_u0 (.a({TW{1'b1}}), .b({4{1'b1}}), .y(yb));
    v5leaf #(.W(6)) g_u1 (.a({TW{1'b0}}), .b({2{2'b10}}), .y(yc));
    // REFUSED shapes (must be identical on both binaries)
    assign r_x   = {TW{1'bx}};            // X element
    assign r_z   = {TW{1'bz}};            // Z element
    assign r_cat = {1'b0, {5{1'b1}}};     // a CONCAT containing a replication
    assign r_zc  = {2'b11, {Z{1'b1}}};    // a ZERO-COUNT replication in a concat
    assign r_nest= {2{{3{1'b1}}}};        // NESTED replications
    assign r_cat2= {{3{1'b1}}, {3{1'b0}}};// concat of TWO replications
    // controls
    assign r_lit = 6'b101010;             // an ALREADY-LITERAL Rhs
    assign r_ctl = {s1, 5'b0};            // a non-constant concat
  end
endmodule
