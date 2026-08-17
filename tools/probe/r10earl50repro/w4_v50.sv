// r10earl50 VERIFIER arm w4 — SELECT SHAPES over a parameter in a cont-assign
// operand position: bit / part / indexed-part, cast-wrapped, nested, concat
// siblings, replication counts, and a select used as another select's INDEX.
module w4_v50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] T1 = 'h1,  // INDEXED part-select operand  A[k +: 4]
  parameter logic [W-1:0] T2 = 'h1,  // CAST-wrapped bit-select      W'(A[0])
  parameter logic [W-1:0] T3 = 'h1,  // concat SIBLING #1 of a two-parameter concat
  parameter logic [W-1:0] T4 = 'h1,  // concat SIBLING #2 of the same concat
  parameter logic [W-1:0] T5 = 'h1,  // bit-select nested THREE operations deep
  parameter logic [W-1:0] T6 = 'h1,  // bit-select used as a REPLICATION count
  parameter logic [W-1:0] T7 = 'h1,  // bit-select used as the INDEX of a param select
  parameter logic [W-1:0] T8 = 'h1,  // the BASE whose index is T7's select
  parameter logic [W-1:0] T9 = 'h1,  // part-select that is the WHOLE module-body RHS
  parameter logic [W-1:0] TA = 'h1,  // bit-select inside $signed()
  parameter logic [W-1:0] TB = 'h1,  // bit-select inside a $clog2() call
  parameter logic [W-1:0] TC = 'h1   // bit-select on the LHS-side index of a CA
) (
  input  logic [W-1:0] n,
  output logic [W-1:0] o1, o2, o3, o5, o6, o7, o9, oa, ob,
  output logic [W-1:0] oc
);
  assign o1 = T1[0 +: 4] | n;                 // T1 indexed part-select
  assign o2 = W'(T2[0]) | n;                  // T2 cast-wrapped
  assign o3 = {T3[0], T4[0], 30'b0} | n;      // T3/T4 concat siblings
  assign o5 = (((T5[0] | 1'b0) | 1'b0) | 1'b0) & n; // T5 nested
  assign o6 = {{31{1'b0}}, {1{T6[0]}}} | n;   // T6 inside a replication VALUE
  assign o7 = {31'b0, T8[T7[2:0]]} | n;       // T7 index select / T8 base
  assign o9 = T9[W-1:0];                      // T9 whole-RHS part-select, MODULE BODY
  assign oa = $signed(TA[0]) | n;             // TA inside $signed
  assign ob = TB[3:0] == 4'h0 ? n : ~n;       // TB part-select as a ternary predicate
  assign oc[TC[2:0]] = n[0];                  // TC on the LHS
endmodule
