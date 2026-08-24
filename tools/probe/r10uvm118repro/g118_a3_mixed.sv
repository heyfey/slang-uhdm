// r10uvm118 arm A3 — the string-concat wrap and the earl72/75 CONSTANT-fold
// typespec stamps in the SAME compile, so neither law can hide the other.
// Rows P* are earl72/75's positive controls (a fold of an unqualified
// wildcard-imported package parameter must KEEP its ref_typespec); rows S* are
// this pass's family (the wrap must be GONE).
package a3p;
  parameter int  NB = 3;
  parameter bit [7:0] TB = 8'hA5;
  parameter      UT = 5;
endpackage

module a3top import a3p::*; (input logic req_i, input logic clk);
  localparam int ML = 4;
  logic [NB-1:0] alloc;
  logic [NB-1:0] c1, p1, p2, p3;
  string s, r;
  int    n;

  // P1  cont-assign replication COUNT fold (earl72 R1 shape)
  assign c1 = {NB{req_i}} & alloc;
  // P2  module-body always_comb operand fold (§ procOpFold9)
  always_comb p1 = {NB{req_i}} & alloc;
  // S1  string concat in the SAME module-body process
  always_comb r = {s, (n > 0 ? "item " : "sequence "), " tail"};

  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gen_b
      logic [NB-1:0] gp;
      string gs;
      // P3  gen-scope always_comb operand fold (§ genScopeProcOpFoldTs75)
      always_comb gp = {NB{req_i}} & alloc;
      // S2  string concat in the SAME gen-scope process
      always_comb gs = {s, (n > 0 ? "item " : "sequence "), " tail"};
      // P4  gen-scope INITIAL: golden has NO constant (earl75 fence a)
      initial gp = {NB{req_i}} & alloc;
      // P5  gen-scope for-stmt bound: golden keeps a ref_obj (earl75 fence b)
      always_comb begin
        for (int k = 0; k < NB; k++) gp[k] = req_i;
      end
    end
  endgenerate

  // P6  task/function body operand fold (§ tfOpFold9)
  function automatic logic [NB-1:0] f3(logic x);
    logic [NB-1:0] t;
    t = {NB{x}};
    // S3  string concat in the SAME function body
    r = {s, (n > 0 ? "item " : "sequence "), " tail"};
    return t;
  endfunction
  always_comb p2 = f3(req_i);

  // P7  QUALIFIED read: the measured NEGATIVE control (folds BARE)
  always_comb p3 = {a3p::NB{req_i}} & alloc;

  // S4  a string concat whose operand is a package string parameter
  localparam string SP = "sp";
  always_comb r = {s, SP, (n > 0 ? "a" : "bb")};
endmodule
