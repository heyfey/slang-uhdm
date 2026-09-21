// r11u74 b3 — LAW B vs THE Rhs KIND.  One gen block; every row's Lhs is a
// gen-local `logic [31:0]` with a MODULE-BODY namesake of the same name, and
// the rows differ only in what the Rhs is.  The question the arm answers:
// does golden's namesake binding depend on the Rhs at all, and does OUR
// binding differ per Rhs kind (the landed suppression laws key on it)?
package p;
  typedef struct packed { int unsigned n; logic [7:0] m; } cfg_t;
  localparam cfg_t LIT = '{n: 300, m: 8'hA5};
endpackage
module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic [31:0] a_i, input logic [31:0] b_i, output logic [31:0] o);
  logic [31:0] r_lit, r_op, r_ref, r_hp, r_tern, r_cast, r_uns, r_cat;
  for (genvar i = 0; i < 1; i = i + 1) begin : gb
    logic [31:0] r_lit, r_op, r_ref, r_hp, r_tern, r_cast, r_uns, r_cat;
    assign r_lit  = 32'd7;                       // bare literal
    assign r_op   = a_i | 32'd0;                 // operation, no unsized
    assign r_ref  = a_i;                         // whole ref
    assign r_hp   = CFG.n;                       // struct-param member read
    assign r_tern = (a_i > b_i) ? a_i : b_i;     // ternary
    assign r_cast = 32'(a_i[7:0]);               // cast operation
    assign r_uns  = a_i | '0;                    // unsized constant inside
    assign r_cat  = {16'd0, a_i[15:0]};          // concat
  end
  assign o = gb[0].r_lit ^ gb[0].r_op ^ gb[0].r_ref ^ gb[0].r_hp
           ^ gb[0].r_tern ^ gb[0].r_cast ^ gb[0].r_uns ^ gb[0].r_cat
           ^ r_lit ^ r_op ^ r_ref ^ r_hp ^ r_tern ^ r_cast ^ r_uns ^ r_cat;
  assign r_lit = 32'd1; assign r_op = 32'd1; assign r_ref = 32'd1;
  assign r_hp = 32'd1;  assign r_tern = 32'd1; assign r_cast = 32'd1;
  assign r_uns = 32'd1; assign r_cat = 32'd1;
endmodule
