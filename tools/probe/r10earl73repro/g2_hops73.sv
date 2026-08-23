// r10earl73 grid g2 — the shapes g1 does not reach: a PARAMETER HOP into an
// arithmetic fold, an ADD with an INT-reduced operand, WIDTH OVERFLOW of the
// formal, a CAST / SHIFT / SYS-CALL wrapped around arithmetic, and negative
// folds into narrow formals.  MEASUREMENT ONLY.
module ch2_int  #(parameter int P = 7) ();       localparam int U = 1; endmodule
module ch2_unt  #(parameter     P = 7) ();       localparam int U = 1; endmodule
module ch2_b4   #(parameter bit [3:0] P = 7) (); localparam int U = 1; endmodule
module ch2_b40  #(parameter bit [39:0] P = 7) (); localparam int U = 1; endmodule
module ch2_opd  #(parameter     P = 4 * 2) ();   localparam int U = 1; endmodule

module top2;
  parameter int A = 256;
  parameter int B = 2;
  parameter int C = 100000;
  localparam int WORDS  = A / B;        // arithmetic-initialised localparam
  localparam int VIA    = WORDS;        // one more hop
  localparam int SUMI   = A + WORDS;    // add whose right operand reduces INT
  localparam int NEGL   = 0 - B;        // negative localparam

  // parameter HOP: a bare ref to an arithmetic-initialised localparam
  ch2_int #(.P(WORDS))         u_int_hop  ();
  ch2_int #(.P(VIA))           u_int_hop2 ();
  ch2_unt #(.P(WORDS))         u_unt_hop  ();
  ch2_b4  #(.P(WORDS))         u_b4_hop   ();
  ch2_opd #(.P(WORDS))         u_opd_hop  ();
  // ADD with an INT-reduced operand
  ch2_int #(.P(A + (B - 1)))   u_int_addi ();
  ch2_int #(.P((A / B) + 1))   u_int_adda ();
  ch2_int #(.P(A + WORDS))     u_int_addh ();
  ch2_int #(.P(SUMI))          u_int_addl ();
  ch2_int #(.P(1 + 8'd4))      u_int_addb ();
  // 64-bit / OVERFLOW arithmetic
  ch2_int #(.P(C * C))         u_int_ovf  ();
  ch2_b4  #(.P(A * B))         u_b4_ovf   ();
  ch2_b40 #(.P(C * C))         u_b40_ovf  ();
  ch2_int #(.P(A * B))         u_int_mul  ();
  // NEGATIVE folds into every formal
  ch2_int #(.P(0 - A))         u_int_negs ();
  ch2_b4  #(.P(0 - B))         u_b4_negs  ();
  ch2_b40 #(.P(0 - B))         u_b40_negs ();
  ch2_unt #(.P(0 - B))         u_unt_negs ();
  ch2_int #(.P(NEGL))          u_int_negh ();
  // WRAPPERS around arithmetic
  ch2_int #(.P(int'(A / B)))   u_int_cast ();
  ch2_int #(.P((A / B) << 1))  u_int_shf  ();
  ch2_int #(.P($clog2(A / B))) u_int_clg  ();
  ch2_int #(.P(((A - B))))     u_int_par  ();
  ch2_int #(.P(unsigned'(A - B))) u_int_uns ();
  ch2_int #(.P((A / B) & 8'hff)) u_int_and ();
  ch2_int #(.P(B ? (A / B) : 3)) u_int_td  ();
  ch2_int #(.P(B ? 3 : (A / B))) u_int_te  ();
  ch2_int #(.P(-(A / B)))      u_int_nd   ();
  ch2_int #(.P(A % B + 1))     u_int_mda  ();
endmodule
