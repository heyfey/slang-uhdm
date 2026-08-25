// r10earl92 grid 5 — HOMES x INSTANCE COUNT, plus the remaining arm shapes.
// The cell shape is fixed at the head's (plain ref_obj Lhs, constant-TRUE bare
// parameter condition, non-value-able arm); only WHERE the cont_assign lives
// and HOW MANY instances exist change.
module g5deep3 #(parameter bit EN = 1) (input logic [7:0][31:0] k, output logic [31:0] o);
  assign o = EN ? k[5] ^ k[1] : k[2] ^ k[3];      // h_deep3
endmodule
module g5deep2 #(parameter bit EN = 1) (input logic [7:0][31:0] k, output logic [31:0] o);
  logic [31:0] w2;
  assign w2 = EN ? k[6] ^ k[1] : k[2] ^ k[3];     // h_deep2
  g5deep3 #(.EN(EN)) u3 (.k(k), .o(o));
endmodule
module g5deep1 #(parameter bit EN = 1) (input logic [7:0][31:0] k, output logic [31:0] o);
  logic [31:0] w1;
  assign w1 = EN ? k[7] ^ k[1] : k[2] ^ k[3];     // h_deep1
  g5deep2 #(.EN(EN)) u2 (.k(k), .o(o));
endmodule

module g5leaf #(parameter bit EN = 1, parameter int N = 2) (
  input logic [7:0][31:0] k, input logic [31:0] sig, output logic [31:0] o);
  // h_module — the plain module home
  logic [31:0] h_module; assign h_module = EN ? k[5] ^ k[1] : k[2] ^ k[3];
  // h_genfor — a gen-for home with a PARAMETER (not genvar) condition
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    logic [31:0] h_genfor; assign h_genfor = EN ? k[5] ^ k[1] : k[2] ^ k[3];
  end
  // h_genif — a gen-if home
  if (1) begin : gi_t
    logic [31:0] h_genif; assign h_genif = EN ? k[5] ^ k[1] : k[2] ^ k[3];
  end
  // h_genblk — an unconditional named generate block
  if (N > 0) begin : gb
    logic [31:0] h_genblk; assign h_genblk = EN ? k[5] ^ k[1] : k[2] ^ k[3];
  end
  // remaining ARM shapes not covered by g3/g4
  logic [31:0] h_arm_rangesel; assign h_arm_rangesel = EN ? {16'b0, k[5][15:0]} : '0;
  logic [31:0] h_arm_bare_rs;  assign h_arm_bare_rs  = EN ? k[5][31:0] : '0;
  logic [31:0] h_arm_repl;     assign h_arm_repl     = EN ? {2{k[5][15:0]}} : '0;
  logic [31:0] h_arm_tern;     assign h_arm_tern     = EN ? (sig[0] ? k[5] : k[1]) : '0;
  assign o = h_module ^ h_arm_rangesel ^ h_arm_bare_rs ^ h_arm_repl ^ h_arm_tern;
endmodule

module g5bindee #(parameter bit EN = 1) (input logic [7:0][31:0] k, output logic [31:0] o);
  assign o = EN ? k[4] ^ k[1] : k[2] ^ k[3];      // h_bindee
endmodule

module g5top (input logic [7:0][31:0] k, input logic [31:0] sig,
              output logic [31:0] a, b, c, d);
  g5leaf  #(.EN(1))          u_a (.k(k), .sig(sig), .o(a));   // 3 instances of g5leaf
  g5leaf  #(.EN(0))          u_b (.k(k), .sig(sig), .o(b));
  g5leaf  #(.EN(1), .N(1))   u_c (.k(k), .sig(sig), .o(c));
  g5deep1 #(.EN(1))          u_d (.k(k), .o(d));              // the 3-deep chain
  g5bindee #(.EN(1))         u_e (.k(k), .o());
endmodule
