// r10earl98 g1 -- THE ANCESTOR DEPTH AXIS of Surelog's write-time
// `bindVariable` walk (CompileStmt.cpp:3089): module_inst levels are SEARCHED,
// gen_scope / gen_scope_array levels are SKIPPED, interface_inst is recursed
// PAST.  One shadowed name per depth, plus one shadowed only in an ancestor
// GEN BLOCK and one shadowed nowhere.
module d1leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] q1, q2;
    logic n_d0;    // shadowed in THIS module's body (the clause we already ship)
    logic n_d1;    // shadowed one module instance up
    logic n_d2;    // shadowed two module instances up
    logic n_d3;    // shadowed three module instances up
    logic n_gen;   // shadowed only in an ancestor GENERATE BLOCK
    logic n_none;  // shadowed nowhere
    assign n_d0  = (q1 == q2);
    assign n_d1  = (q1 != q2);
    assign n_d2  = (q1 < q2);
    assign n_d3  = (q1 > q2);
    assign n_gen = (q1 <= q2);
    assign n_none = (q1 >= q2);
    assign o = n_d0 ^ n_d1 ^ n_d2 ^ n_d3 ^ n_gen ^ n_none;
    always_ff @(posedge clk) begin
      q1 <= a;
      q2 <= q1;
    end
  end
  logic n_d0;
  assign n_d0 = 1'b0;
endmodule

module d1mid98 (input logic clk, input logic [1:0] a, output logic o);
  logic n_d1;
  assign n_d1 = 1'b0;
  d1leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule

module d1outer98 (input logic clk, input logic [1:0] a, output logic o);
  logic n_d2;
  assign n_d2 = 1'b0;
  d1mid98 u_mid (.clk(clk), .a(a), .o(o));
endmodule

module g1_depth98 (input logic clk, input logic [1:0] a, output logic o);
  logic n_d3;
  assign n_d3 = 1'b0;
  if (1) begin : gen_anc
    logic n_gen;                 // an ANCESTOR GEN BLOCK's local: skipped
    assign n_gen = 1'b0;
    d1outer98 u_outer (.clk(clk), .a(a), .o(o));
  end
endmodule
