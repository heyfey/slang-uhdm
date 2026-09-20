// wb_scoped -- a typedef written over a SCOPED name (pk::T) in each home.
// aliasHomeNeverRebound67 calls every package/$unit typedef-over-a-name a
// DummyType; a SCOPED target is the counter-example.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
  typedef cv_t        cv2_t;
  typedef cv_t [1:0]  cw_t;
endpackage
package pb;
  typedef pk::cv_t  bq_t;
  typedef pk::cr_t  bqr_t;
  typedef pk::cv2_t bq2_t;
endpackage
typedef pk::cv_t   uq_t;
typedef pk::cr_t   uqr_t;
typedef pk::cv2_t  uq2_t;
typedef pk::cw_t   uqw_t;
typedef pk::cv_t [1:0] uqd_t;
module wb;
  typedef pk::cv_t  mq_t;
  typedef pk::cr_t  mqr_t;
  typedef pk::cv2_t mq2_t;
  uq_t   y01;   wire uq_t   y02;
  uqr_t  y03;   wire uqr_t  y04;
  uq2_t  y05;   wire uq2_t  y06;
  uqw_t  y07;   wire uqw_t  y08;
  uqd_t  y09;   wire uqd_t  y10;
  pb::bq_t  y11;
  pb::bqr_t y12;
  mq_t   y13;   wire mq_t   y14;
  mqr_t  y15;   wire mqr_t  y16;
  mq2_t  y17;   wire mq2_t  y18;
  uq_t   y19 [2];
endmodule
module wb2;
  import pb::*;
  bq_t   y20;   wire bq_t   y21;
  bqr_t  y22;   wire bqr_t  y23;
  bq2_t  y24;   wire bq2_t  y25;
endmodule
