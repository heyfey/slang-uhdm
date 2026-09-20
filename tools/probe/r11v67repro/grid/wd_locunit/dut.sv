// wd_locunit -- a MODULE-LOCAL typedef written over a $unit alias, by whether
// that $unit alias was itself written over a SCOPED name or an unqualified one.
// This is the cell where the r11v67 fence and the shipped law disagree.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
typedef pk::cv_t uq_t;      // $unit, SCOPED target  -> bound
typedef pk::cr_t uqr_t;
typedef logic [1:0] uv_t;   // $unit, SimpleType
typedef uv_t     ub_t;      // $unit, unqualified target -> never bound
module wd;
  typedef uq_t  m1_t;
  typedef uqr_t m2_t;
  typedef uv_t  m3_t;
  typedef ub_t  m4_t;
  m1_t  c01;   wire m1_t c02;
  m2_t  c03;   wire m2_t c04;
  m3_t  c05;   wire m3_t c06;
  m4_t  c07;   wire m4_t c08;
endmodule
