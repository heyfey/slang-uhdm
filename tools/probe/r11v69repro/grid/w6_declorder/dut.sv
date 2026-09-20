// r11v69 w6 — DECLARATION ORDER and the COMMA-LIST span.  A module-body target
// declared AFTER the generate block that writes it, a comma-list continuous
// assign inside a generate block (every cont_assign takes the whole list's
// span, a landed quirk) and a second generate block writing a target declared
// between them.  All three fire the law; the order must not change the answer.
package p;
  typedef struct packed { int unsigned n; int unsigned m; } cfg_t;
  localparam cfg_t LIT = '{n: 5, m: 9};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [31:0] o_a, o_b, o_c, o_d);

  if (1) begin : gearly
    assign late_v = CFG.n;          // target declared BELOW
  end

  logic [31:0] mid_v;

  if (1) begin : gcomma
    assign mid_v = CFG.n, o_b = CFG.m;   // comma list inside a gen block
  end

  logic [31:0] late_v;

  if (1) begin : glate
    assign o_c = CFG.m;
  end

  assign o_a = late_v;
  assign o_d = mid_v;
endmodule
