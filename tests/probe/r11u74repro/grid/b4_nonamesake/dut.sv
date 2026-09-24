// r11u74 b4 — THE CONTROL FOR LAW B: the SAME Rhs grid as b3 with NO outer
// namesake for any target.  If golden is unbound on every row, the rule is
// "never the own gen-local"; if golden binds the own local on some Rhs kinds,
// the law must keep those.
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{n: 300, m: 8'hA5};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic [31:0] a_i, input logic [31:0] b_i, output logic [31:0] o);
  for (genvar i = 0; i < 1; i = i + 1) begin : gb
    logic [31:0] q_lit, q_op, q_ref, q_hp, q_tern, q_cast, q_uns, q_cat;
    wire  [31:0] q_net;
    assign q_lit  = 32'd7;
    assign q_op   = a_i | 32'd0;
    assign q_ref  = a_i;
    assign q_hp   = CFG.n;
    assign q_tern = (a_i > b_i) ? a_i : b_i;
    assign q_cast = 32'(a_i[7:0]);
    assign q_uns  = a_i | '0;
    assign q_cat  = {16'd0, a_i[15:0]};
    assign q_net  = a_i | 32'd0;
  end
  assign o = gb[0].q_lit ^ gb[0].q_op ^ gb[0].q_ref ^ gb[0].q_hp
           ^ gb[0].q_tern ^ gb[0].q_cast ^ gb[0].q_uns ^ gb[0].q_cat
           ^ gb[0].q_net;
endmodule
