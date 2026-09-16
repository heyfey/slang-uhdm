// xb7 - WHERE does a concat block the whole-Rhs substitution inside a conditional?
package pk;
  parameter logic [3:0] C0 = 4'b0001;
  parameter logic [3:0] C3 = 4'b0011;
  // V1: condition is a plain ref, branch is a concat            (the S5 shape)
  parameter logic [3:0] V1 = C0 ? {C0} : C3;
  // V2: condition is an EQ of a ref and a literal, branch concat
  parameter logic [3:0] V2 = (C0 == 4'b0001) ? {C0} : C3;
  // V3: condition CONTAINS a concat, branches plain
  parameter logic [3:0] V3 = ({C0[1:0], C3[1:0]} == 4'b0111) ? C0 : C3;
  // V4: condition plain ref, branch is a replication
  parameter logic [3:0] V4 = C0 ? {2{C0[1:0]}} : C3;
  // V5: condition plain ref, branch is a concat of LITERALS only
  parameter logic [3:0] V5 = C0 ? {2'b01, 2'b10} : C3;
  // V6: nested conditional, inner branch concat
  parameter logic [3:0] V6 = C0 ? (C3 ? {C0} : C3) : C3;
  // V7: conditional under a cast, branch concat (the Z5 shape, plain condition)
  parameter logic [3:0] V7 = 4'(C0 ? {C0} : C3);
endpackage
module top;
  logic [3:0] a = pk::V1 ^ pk::V2 ^ pk::V3 ^ pk::V4 ^ pk::V5 ^ pk::V6 ^ pk::V7;
endmodule
