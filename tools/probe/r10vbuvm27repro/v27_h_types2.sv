package pT;
  typedef struct packed { bit [3:0] a; bit [7:0] b; } ps_t;
  typedef ps_t psarr_t [3];                     // 36
  typedef logic [3:0][7:0] mm_t;                // 32
  typedef enum logic [4:0] { A0, A1 } en_t;     // 5
  class CT;
    psarr_t   pa;                 // 36
    mm_t      mm  [2];            // 64
    en_t      en  [3];            // 15
    bit       wa  [*];            // 1  (wildcard assoc)
    byte      qb  [$:3];          // 8  (bounded queue)
    bit [7:0] nest [2][3][4];     // 192
    logic [15:0] sgn;
    byte unsigned be;
    int r; int i;
    static bit [7:0] sarr [4];    // 32 static prop
    const int ci = 5;
    function void m();
      r = $bits(pa[i]   & 12'd1);   // t01
      r = $bits(mm[i]   & 32'd1);   // t02
      r = $bits(en[i]   & 5'd1);    // t03
      r = $bits(wa[3]   & 1'b1);    // t04
      r = $bits(qb[i]   & be);      // t05
      r = $bits(nest[i][1][2] & be);// t06
      r = $bits(sgn[7:0] & be);     // t07  -> 16
      r = $bits(sarr[i]  & be);     // t08  static prop -> 32
      // single-argument twins
      r = $bits(pa[i]); r = $bits(mm[i]); r = $bits(en[i]); r = $bits(wa[3]);
      r = $bits(qb[i]); r = $bits(nest[i][1][2]); r = $bits(sgn[7:0]); r = $bits(sarr[i]);
      $display("%0d", r);
    endfunction
  endclass
endpackage
module vT; import pT::*; initial begin CT c = new(); c.m(); end endmodule
