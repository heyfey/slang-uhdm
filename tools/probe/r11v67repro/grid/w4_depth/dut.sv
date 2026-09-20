// w4_depth -- chain DEPTH (1..4) x home, dimension-less and packed-dimensioned.
// Names chosen so each typedef sorts AFTER its target (the bind-ORDER caveat),
// so golden reads the REBOUND answer wherever rebinding happens at all.
package pk;
  typedef logic [1:0] a_t;
  typedef a_t         b_t;
  typedef b_t         c_t;
endpackage
typedef logic [1:0] ua_t;
typedef ua_t        ub_t;
module w4;
  import pk::*;
  typedef logic [1:0] la_t;
  typedef la_t        lb_t;
  typedef lb_t        lc_t;
  typedef lc_t        ld_t;
  typedef reg  [1:0]  ra_t;
  typedef ra_t        rb_t;
  typedef rb_t        rc_t;
  typedef la_t [1:0]  pa_t;
  typedef pa_t [1:0]  pb_t;
  typedef a_t         ma_t;   // LOCAL over PACKAGE simple
  typedef ma_t        mb_t;   // LOCAL over LOCAL over PACKAGE simple
  typedef ua_t        na_t;   // LOCAL over $unit simple
  la_t d01;  lb_t d02;  lc_t d03;  ld_t d04;
  ra_t d05;  rb_t d06;  rc_t d07;
  pa_t d08;  pb_t d09;
  ma_t d10;  mb_t d11;  na_t d12;
  a_t  d13;  b_t  d14;  c_t  d15;
  ua_t d16;  ub_t d17;
  wire la_t d18;  wire lb_t d19;  wire lc_t d20;
  wire ra_t d21;  wire rb_t d22;
  wire ma_t d23;  wire mb_t d24;
  wire b_t  d25;  wire c_t  d26;
  wire ub_t d27;
endmodule
