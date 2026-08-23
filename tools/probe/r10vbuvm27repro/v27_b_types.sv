// r10vbuvm27 ARM B -- LEFTMOST-OPERAND TYPE MATRIX for $bits(<binary>)
package pB2;
  typedef struct packed   { bit [3:0] a; bit [7:0] b; } ps_t;      // 12
  typedef struct          { bit [3:0] a; bit [7:0] b; } us_t;      // unpacked 12
  typedef union  packed   { bit [7:0] u1; bit [7:0] u2; } pu_t;    // 8
  typedef enum bit [2:0]  { E0, E1 } e_t;                          // 3
  parameter int PW = 5;
  parameter int NW = 3;

  class CB;
    bit                  b1  [4];      // 4
    bit  [0:0]           bv1 [3];      // 3
    logic [64:0]         w65 [2];      // 130
    logic signed [7:0]   sg  [3];      // 24
    logic [PW-1:0]       pw4 [2];      // 10
    byte unsigned        dyn [];       // 8
    byte unsigned        q   [$];      // 8
    byte unsigned        aa  [string]; // 8
    byte unsigned        d2  [][];     // 8
    ps_t                 psa [2];      // 24
    us_t                 usa [2];      // 24
    pu_t                 pua [2];      // 16
    e_t                  ea  [2];      // 6
    int                  ia  [3];      // 96
    real                 ra  [2];      // 64?
    string               sa  [2];      // ?
    time                 ta  [2];      // ?
    bit [7:0]            m23 [2][3];   // 48
    byte unsigned        be;
    int r; int i;
    function void m();
      r = $bits(b1[i]   & 1'b1);   // c01
      r = $bits(bv1[i]  & 1'b1);   // c02
      r = $bits(w65[i]  & 65'd1);  // c03
      r = $bits(sg[i]   & 8'd1);   // c04
      r = $bits(pw4[i]  & 5'd1);   // c05
      r = $bits(dyn[i]  & be);     // c06
      r = $bits(q[i]    & be);     // c07
      r = $bits(aa["k"] & be);     // c08
      r = $bits(d2[i][i]& be);     // c09
      r = $bits(psa[i]  & 12'd1);  // c10
      r = $bits(pua[i]  & 8'd1);   // c11
      r = $bits(ea[i]   & 3'd1);   // c12
      r = $bits(ia[i]   & 32'd1);  // c13
      r = $bits(ra[i]   + 1.0);    // c14
      r = $bits(sa[i]   == "z");   // c15
      r = $bits(ta[i]   & 64'd1);  // c16
      r = $bits(m23[i][1] & 8'd1); // c17
      r = $bits(usa[i] == usa[i]); // c18 unpacked struct element
      // single-argument twins
      r = $bits(b1[i]); r = $bits(w65[i]); r = $bits(sg[i]);
      r = $bits(psa[i]); r = $bits(ea[i]); r = $bits(ra[i]);
      r = $bits(m23[i][1]);
      $display("%0d", r);
    endfunction
  endclass
endpackage
module vB;
  import pB2::*;
  initial begin CB c = new(); c.m(); end
endmodule
