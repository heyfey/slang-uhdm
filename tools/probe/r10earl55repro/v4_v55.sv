// v55 adversarial arm 4 — PORT-LIST parameters (the census's "KEEP" class) and
// the OVERRIDE ladder.  CENSUS_PREDICT55 claims an overridden width-1 port-list
// parameter keeps a LOCATED logic_typespec and does not move; this arm asks the
// same question for the NON-overridden default, a defparam-free hierarchy, and
// a port-list param whose default IS a replication.
// MEASURED (both views, both binaries): TO-GOLDEN 6 / AWAY-GOLDEN 0 /
// STILL-WRONG 0.  A PORT-LIST parameter whose DEFAULT is a width-1 replication
// takes the int_typespec too, in the kept-default instance and in both
// overridden ones; two elab clones of one module at N=1 and N=2 answer
// independently (the N=1 clone moves, the N=2 clone stays R1).
module v4_v55(input logic ext);
  q0_v55           u_q0 (.o(), .ext(ext));   // default kept
  q0_v55 #(.P(1'b0)) u_q1 (.o(), .ext(ext)); // overridden with a literal
  q0_v55 #(.P({1{1'b0}})) u_q2 (.o(), .ext(ext)); // overridden with a replication
  q1_v55           u_q3 (.o(), .ext(ext));
  q2_v55           u_q4 (.o(), .ext(ext));
endmodule

// port-list width-1 param whose DEFAULT is a replication
module q0_v55 #(parameter logic [0:0] P = {1{1'b1}})
               (output logic o, input logic ext);
  assign o = ext ^ P[0];
endmodule

// a body localparam width-1 fold that DEPENDS on a port-list param
module q1_v55 #(parameter int N = 1) (output logic o, input logic ext);
  localparam logic [N-1:0] S = {N{1'b1}};
  localparam logic [0:0]   T = {1{S[0]}};
  assign o = ext ^ T[0];
endmodule

// two instances of the SAME module, different overrides -> two elab clones
module q2_v55 (output logic o, input logic ext);
  q1_v55 #(.N(1)) u_n1 (.o(), .ext(ext));
  q1_v55 #(.N(2)) u_n2 (.o(), .ext(ext));
  assign o = ext;
endmodule
