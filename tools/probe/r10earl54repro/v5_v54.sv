// v54 VERIFIER ARM v5 — DEPTH AND ODD POSITIONS INSIDE ONE ACTUAL.
// The walk is recursive over operation operands and replaces the FIRST
// matching multiconcat it meets, never descending into it.  Depth 5, a
// replication inside a PART-SELECT BOUND, inside a FUNCTION CALL argument and
// inside a SYSTEM function argument are the positions that are reached through
// a non-operation link (range/argument vectors) rather than Operands().
module snkv5_54 #(parameter int WD = 8) (input [WD-1:0] a, output [WD-1:0] o);
  assign o = ~a;
endmodule
function automatic [7:0] fv5_54 (input [7:0] x);
  return ~x;
endfunction
module v5_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w1, w2, w3, w4, w5;
  // DEPTH 5: concat > ternary > binary > ternary > concat > replication
  snkv5_54 #(.WD(8)) u_d5 (
      .a({ sel ? (d[3:0] & (sel ? {2'b11, {2{1'b1}}} : 4'h0)) : 4'h0, 4'h1 }), .o(w1));
  // replication inside a PART-SELECT BOUND
  snkv5_54 #(.WD(8)) u_bnd (.a({ d[ $bits({4{1'b0}}) - 1 : 0], 4'h2 }), .o(w2));
  // replication inside a FUNCTION-CALL argument
  snkv5_54 #(.WD(8)) u_fc  (.a(fv5_54({ {4{1'b1}}, 4'h3 })), .o(w3));
  // replication inside a SYSTEM-function argument
  snkv5_54 #(.WD(8)) u_sf  (.a({ 4'($countones({4{1'b1}})), 4'h4 }), .o(w4));
  // TWO sibling replications in one actual, both foldable
  snkv5_54 #(.WD(8)) u_two (.a({ sel ? {4{1'b0}} : 4'h5, sel ? 4'h6 : {4{1'b1}} }), .o(w5));
  assign q = w1 ^ w2 ^ w3 ^ w4 ^ w5;
endmodule
