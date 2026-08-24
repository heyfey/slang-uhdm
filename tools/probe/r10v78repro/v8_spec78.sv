// r10v78 arm v8 — PARAMETER SPECIALIZATIONS: the same module definition
// instantiated with DIFFERENT parameter values, each holding a gen-scope
// replication whose COUNT and TARGET WIDTH both come from the parameter.
// A fold that leaked across specializations would show here.
module v8sub #(parameter int W = 3, parameter int T = 4) ();
  logic [T-1:0] s_t;
  logic [T-1:0] s_u;
  if (W > 0) begin : g8
    assign s_t = {W{1'b1}};        // natural W, target T
  end
  for (genvar k = 0; k < 2; k++) begin : g8f
    if (k == 0) assign s_u = {(W+k){1'b1}};
  end
endmodule
module v8;
  v8sub #(.W(3),  .T(4))  u_a ();   // natural 3  -> target 4  => 3
  v8sub #(.W(6),  .T(4))  u_b ();   // natural 6  -> target 4  => 4
  v8sub #(.W(6),  .T(10)) u_c ();   // natural 6  -> target 10 => 6
  v8sub #(.W(65), .T(10)) u_d ();   // natural 65 (>64)        => 65
  v8sub #(.W(64), .T(10)) u_e ();   // natural 64              => 10
endmodule
