// r11u84 t4 - DOES THE EXPLICIT-IMPORT CLONE TAKE THE ELABORATED READING TOO?
// Same pointer, same filter: an explicit import pushes the SAME ELAB Signal
// the wildcard one does, only one of them.  If R0's mechanism is the shared
// pointer, an explicitly-imported one-hop typedef net must read 36 in the DEF
// view as well, and the wildcard control beside it must agree cell for cell.
package p1;
  typedef logic [7:0] a1_t;
  typedef a1_t        a2_t;
  typedef a2_t        a3_t;
  typedef reg  [7:0]  r1_t;
  typedef r1_t        r2_t;
  typedef struct packed { logic m; logic n; } g1_t;
  typedef g1_t        g2_t;
  wire a1_t   k_wa1;      // one hop  -> elab nt 36
  wire a2_t   k_wa2;      // two hops -> elab nt 1
  wire a3_t   k_wa3;      // three hops
  wire r1_t   k_wr1;
  a1_t        k_a1;
  a2_t        k_a2;
  a3_t        k_a3;
  r1_t        k_r1;
  r2_t        k_r2;
  g1_t        k_g1;
  g2_t        k_g2;
  logic [7:0] k_ua [0:2];
  wire        k_plain;
endpackage

package p2;                       // EXPLICIT, one item per entry
  import p1::k_wa1; import p1::k_wa2; import p1::k_wa3; import p1::k_wr1;
  import p1::k_a1;  import p1::k_a2;  import p1::k_a3;
  import p1::k_r1;  import p1::k_r2;
  import p1::k_g1;  import p1::k_g2;
  import p1::k_ua;  import p1::k_plain;
  logic [7:0] own2;
endpackage

package p3;  import p1::*;  logic [7:0] own3; endpackage   // the WILDCARD control

module dut (output logic [31:0] o);
  import p2::*; import p3::*;
  assign o = {24'd0, own2 ^ own3};
endmodule
