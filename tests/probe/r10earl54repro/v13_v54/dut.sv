// v54 VERIFIER ARM v13 — THE BIND PATH, WIDENED.
// a3 measured ONE bound instance in ONE parent.  The line the arm sits next to
// picks `currentTopPrefix` over `parentPrefix` only when a bindPath is active,
// and the arm deliberately uses `prefix`.  This widens it: the same bound module
// bound into a target that is instantiated TWICE, a bind into a GENERATE scope,
// and a bind whose actual reaches a signal of the TARGET (not the binder).
module snk13_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module tgt13_54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] w;
  snk13_54 u_in (.a({sel ? d[3:0] : {4{1'b0}}, 4'h1}), .o(w));
  for (genvar gi = 0; gi < 2; gi++) begin : gen_t13
    logic [7:0] gw;
    snk13_54 u_g (.a({sel ? d[3:0] : {4{1'b1}}, 4'h2}), .o(gw));
  end
  assign q = w;
endmodule
module probe13_54 (input logic [7:0] pa, output logic [7:0] po);
  assign po = pa;
endmodule
module v13_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  logic [7:0] q1, q2;
  tgt13_54 u_t1 (.sel(sel), .d(d),      .q(q1));
  tgt13_54 u_t2 (.sel(sel), .d(~d),     .q(q2));
  assign q = q1 ^ q2;
endmodule
// ONE bind statement, TWO target instances -> two bound instances
bind tgt13_54 probe13_54 u_bound (.pa({sel ? d[3:0] : {4{1'b1}}, 4'h3}), .po());
