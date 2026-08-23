// r10v73 v6 — LEAF-TRUNCATION, package/interface homes, deep chains, overflow,
// and the unpacked-array-dimension carrier (R0's family).  MEASUREMENT ONLY.
package pk6;
  parameter int PA6   = 256;
  parameter int PB6   = 2;
  localparam int PDIV = PA6 / PB6;      // package-level arithmetic localparam
  localparam int PSUB = PA6 - PB6;
endpackage

interface if6 #(parameter int IW = 8) ();
  localparam int IW2 = IW * 2;
  logic [IW-1:0] d;
endinterface

module ch6 #(parameter int P = 7) ();  localparam int U = 1; endmodule
module ch6b #(parameter bit [7:0] P = 7) (); localparam int U = 1; endmodule
module ch6d #(parameter int D = 4, parameter int W = 8) ();
  logic [W-1:0] mem [D];               // R0's carrier: unpacked-array dimension
  localparam int DD = D;
endmodule
module ch6h #(parameter int H = 1) ();
  ch6 #(.P(H * 2)) u_in ();            // a hop that folds again
endmodule

module topv6;
  import pk6::*;
  parameter int A = 256;
  parameter int B = 2;
  // H1 TRUNCATED LEAF: slang stores T8 = 8'h34 (52); Surelog may keep 4660.
  localparam bit  [7:0] T8  = 16'h1234;
  localparam logic [3:0] T4 = 8'hAB;
  localparam int        TNEG = -8;
  ch6 #(.P(T8 * 2))      u_t8   ();
  ch6 #(.P(T4 * 2))      u_t4   ();
  ch6 #(.P(T8 - 1))      u_t8s  ();
  // H2 PACKAGE-level arithmetic localparam as an actual and as a hop
  ch6 #(.P(PDIV))        u_pk   ();
  ch6 #(.P(PDIV + 1))    u_pka  ();
  ch6 #(.P(pk6::PSUB))   u_pkq  ();
  ch6 #(.P(pk6::PA6 / pk6::PB6)) u_pkd ();
  // H4 SIGNED NEGATIVE leaf
  ch6 #(.P(TNEG * 3))    u_neg  ();
  ch6 #(.P(TNEG / 2))    u_negd ();
  ch6 #(.P(TNEG % 3))    u_negm ();
  ch6b #(.P(TNEG * 3))   u_negb ();
  // H6 POWER overflow / big exponent
  ch6 #(.P(2 ** 30))     u_p30  ();
  ch6 #(.P(2 ** 62))     u_p62  ();
  ch6 #(.P(2 ** 64))     u_p64  ();
  ch6 #(.P(2 ** 100))    u_p100 ();
  // H7 DEEP chain of hops
  localparam int C1 = A / B;
  localparam int C2 = C1 - 1;
  localparam int C3 = C2 * 2;
  localparam int C4 = C3 + 1;
  localparam int C5 = C4 % 100;
  localparam int C6 = C5 * C5;
  ch6 #(.P(C6))          u_deep ();
  ch6 #(.P(((((A/B)-1)*2)+1)%100)) u_deepe ();
  // H8 hop through a module whose own param was overridden with arithmetic
  ch6h #(.H(A / B))      u_hop  ();
  ch6h #(.H(A))          u_hop2 ();
  // H9 R0's carrier: an arithmetic override feeding an unpacked dimension
  ch6d #(.D(A / B), .W(A / 32)) u_arr  ();
  ch6d #(.D(A * B), .W(8))      u_arr2 ();
  // H10 gen-if / gen-for homes over the same shapes
  generate if (A > B) begin : g6
    ch6 #(.P(A / B))     u_gif  ();
    localparam int GL = A * B;
    ch6 #(.P(GL - 1))    u_gifl ();
  end endgenerate
  // interface home
  if6 #(.IW(A / 32))     u_if   ();
  if6 #(.IW(A - 248))    u_if2  ();
endmodule
