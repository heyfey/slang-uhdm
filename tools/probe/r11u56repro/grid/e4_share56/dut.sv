// r11u56 arm e4 — MUTATION SAFETY AND THE NON-PLAIN Lhs.  The encoding law
// rewrites the constant IN PLACE, so: (a) one member read by THREE assigns of
// the SAME instance at three Lhs widths (golden shares ONE object and the last
// writer's width wins — the r11v55 R5 residue), (b) a SECOND instance of the
// same definition ("clone, never share"), (c) a bit-select / part-select Lhs,
// where the producer's Lhs-level adjustSize returns at once.
package p;
  typedef enum logic [3:0] { E_A = 4'd2, E_B = 4'd9 } e_t;
  typedef struct packed {
    logic [31:0] u1;   // '1
    int          sn;   // -1
    e_t          ev;   // enum member
    logic [15:0] pl;   // plain decimal
  } cfg_t;
  localparam cfg_t LIT = '{u1: '1, sn: -1, ev: E_B, pl: 300};
endpackage
module leaf #(parameter p::cfg_t C = p::LIT)
            (output logic [7:0] a, output logic [31:0] b, output logic [63:0] c,
             output logic signed [31:0] d, output logic [31:0] e,
             output logic [31:0] f, output logic [31:0] g);
  assign a = C.u1;     // narrow
  assign b = C.u1;     // equal
  assign c = C.u1;     // wide   (one member, three assigns, one instance)
  assign d = C.sn;
  assign e = C.ev;
  assign f[3:0] = C.pl;   // PART-SELECT Lhs
  assign g[0]   = C.sn;   // BIT-SELECT Lhs
endmodule
module dut (output logic [7:0] a1, output logic [31:0] b1, output logic [63:0] c1,
            output logic signed [31:0] d1, output logic [31:0] e1,
            output logic [31:0] f1, output logic [31:0] g1,
            output logic [7:0] a2, output logic [31:0] b2, output logic [63:0] c2,
            output logic signed [31:0] d2, output logic [31:0] e2,
            output logic [31:0] f2, output logic [31:0] g2);
  leaf u_1 (.a(a1), .b(b1), .c(c1), .d(d1), .e(e1), .f(f1), .g(g1));
  leaf u_2 (.a(a2), .b(b2), .c(c2), .d(d2), .e(e2), .f(f2), .g(g2));
endmodule
