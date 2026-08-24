// r10v123 arm C — the KIND grid.  Fence 2 says only RANGED bit/logic move.
// Every other ELAB-listing typedef shape must stay EXACTLY where it was.
package gum123_pkg;
  parameter int GUM_W = 4;
  typedef bit  [7:0]                gum_bit_t;      // MOVES
  typedef logic [GUM_W-1:0]         gum_log_t;      // MOVES
  typedef bit                       gum_scalar_t;   // rangeless bit: STAYS
  typedef logic                     gum_lscalar_t;  // rangeless logic: STAYS
  typedef int                       gum_int_t;      // STAYS
  typedef integer                   gum_integer_t;  // STAYS
  typedef byte                      gum_byte_t;     // STAYS
  typedef shortint                  gum_short_t;    // STAYS
  typedef longint                   gum_long_t;     // STAYS
  typedef enum bit [2:0] {G_A, G_B, G_C} gum_enum_t; // STAYS
  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } gum_st_t;  // STAYS
  typedef union  packed { bit [7:0] a;  bit [7:0] b;  } gum_un_t;  // STAYS
  typedef bit  [1:0][7:0]           gum_2d_t;       // multi-dim packed
  typedef bit  [7:0]                gum_elem_t;
  typedef gum_elem_t [2:0]          gum_parr_t;     // packed array of typedef
  function automatic int gum_home(int qq);
    gum_bit_t     v1; gum_log_t   v2; gum_scalar_t v3; gum_lscalar_t v4;
    gum_int_t     v5; gum_integer_t v6; gum_byte_t v7; gum_short_t   v8;
    gum_long_t    v9; gum_enum_t  va; gum_st_t     vb; gum_un_t      vc;
    gum_2d_t      vd; gum_parr_t  ve;
    v1 = gum_bit_t'(qq);
    v2 = gum_log_t'(qq);
    v3 = gum_scalar_t'(qq);
    v4 = gum_lscalar_t'(qq);
    v5 = gum_int_t'(qq);
    v6 = gum_integer_t'(qq);
    v7 = gum_byte_t'(qq);
    v8 = gum_short_t'(qq);
    v9 = gum_long_t'(qq);
    va = gum_enum_t'(qq);
    vb = gum_st_t'(qq);
    vc = gum_un_t'(qq);
    vd = gum_2d_t'(qq);
    ve = gum_parr_t'(qq);
    return int'(v1) + int'(v2) + int'(v3) + int'(v4) + int'(v5) + int'(v6) +
           int'(v7) + int'(v8) + int'(v9) + int'(va) + int'(vb) + int'(vc) +
           int'(vd) + int'(ve);
  endfunction
endpackage

package hazel123_pkg;
  import gum123_pkg::*;
  function automatic int hazel_use(int qq);
    gum_bit_t  w1; gum_enum_t w2; gum_st_t w3; gum_2d_t w4; gum_parr_t w5;
    gum_int_t  w6;
    w1 = gum_bit_t'(qq);
    w2 = gum_enum_t'(qq);
    w3 = gum_st_t'(qq);
    w4 = gum_2d_t'(qq);
    w5 = gum_parr_t'(qq);
    w6 = gum_int_t'(qq);
    return int'(w1) + int'(w2) + int'(w3) + int'(w4) + int'(w5) + int'(w6);
  endfunction
endpackage

module gum_top;
  import gum123_pkg::*;
  initial begin
    int rr;
    rr = gum_home(2) + hazel123_pkg::hazel_use(3);
  end
endmodule
