// r10buvm11 arm w2 — THE ELEMENT-KIND GRID at the head's shape (2-D leading
// associative), plus the 1-D and FIXED controls.  MEASUREMENT ONLY.
package pk11b;
  typedef bit          b_t;
  typedef bit [7:0]    bv_t;
  typedef b_t          b2_t;
  typedef logic        l_t;
  typedef enum bit {E0, E1} e_t;
  typedef struct packed { bit a; bit b; } ps_t;
  typedef struct { bit a; int b; }        us_t;
  class hcls11; int h; endclass
  class w2_cls;
    bit              e_bit     [int][int];
    bit [7:0]        e_bitv    [int][int];
    bit signed [3:0] e_bits    [int][int];
    logic            e_log     [int][int];
    logic [7:0]      e_logv    [int][int];
    int              e_int     [int][int];
    int unsigned     e_uint    [int][int];
    byte             e_byte    [int][int];
    shortint         e_sint    [int][int];
    longint          e_lint    [int][int];
    integer          e_integer [int][int];
    time             e_time    [int][int];
    real             e_real    [int][int];
    shortreal        e_sreal   [int][int];
    string           e_str     [int][int];
    chandle          e_chand   [int][int];
    hcls11           e_cls     [int][int];
    b_t              e_btd     [int][int];
    b2_t             e_b2td    [int][int];
    bv_t             e_bvtd    [int][int];
    l_t              e_ltd     [int][int];
    e_t              e_enum    [int][int];
    ps_t             e_pstruct [int][int];
    us_t             e_ustruct [int][int];
    // ---- 1-D controls: nothing may appear on either side.
    bit              c_bit1    [int];
    bit [7:0]        c_bitv1   [int];
    b_t              c_btd1    [int];
    // ---- FIXED controls: the array_var HAS ranges here.
    bit              c_bitf    [4];
    bit [7:0]        c_bitvf   [4];
    b_t              c_btdf    [4];
    logic            c_logf    [4];
    int              c_intf    [4];
    string           c_strf    [4];
  endclass
endpackage
module w2v_elem11_top;
  pk11b::w2_cls u = new();
endmodule
