// v11u79 q3 — TYPEDEF CHAINS AND THE ONE-HOP NET-TYPE REWRITE.  LAW C reads
// exactly one hop through TypedefDeclarationSyntax.  A TYPE PARAMETER is a
// TypeAlias whose syntax is NOT a TypedefDeclaration: pre-79 stamped it 36 in
// the elaborated view, r11u79 stamps nothing.  Which is golden's?
package q3base;
  typedef logic [3:0] b_t;
endpackage

package q3;
  import q3base::b_t;
  typedef logic [7:0] h1_t;          // one hop
  typedef h1_t        h2_t;          // two hops
  typedef h2_t        h3_t;          // three hops
  h1_t                c_h1;
  h2_t                c_h2;
  h3_t                c_h3;
  wire h1_t           c_wh1;
  wire h2_t           c_wh2;
  wire h3_t           c_wh3;
  typedef reg [7:0]   r1_t;
  typedef r1_t        r2_t;
  r1_t                c_r1;
  r2_t                c_r2;
  wire r1_t           c_wr1;
  typedef logic [1:0][7:0] pa_t;
  pa_t                c_pa;
  wire pa_t           c_wpa;
  b_t                 c_imp;         // a typedef IMPORTED from another package
  wire b_t            c_wimp;
  parameter type      T_t = logic [7:0];
  T_t                 c_tparam;      // a TYPE PARAMETER, not a typedef
  typedef bit [7:0]   bt_t;
  typedef bt_t        bt2_t;
  bt2_t               c_bt2;
endpackage

module dut (output logic [31:0] o);
  import q3::*;
  assign o = {24'd0, c_h1} ^ {24'd0, c_h2} ^ {24'd0, c_h3}
           ^ {24'd0, c_wh1} ^ {24'd0, c_wh2} ^ {24'd0, c_wh3}
           ^ {24'd0, c_r1} ^ {24'd0, c_r2} ^ {24'd0, c_wr1}
           ^ {16'd0, c_pa} ^ {16'd0, c_wpa} ^ {28'd0, c_imp}
           ^ {28'd0, c_wimp} ^ {24'd0, c_tparam} ^ {24'd0, c_bt2};
endmodule
