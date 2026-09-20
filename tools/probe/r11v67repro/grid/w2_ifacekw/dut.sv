// w2_ifacekw -- LAW C's blast radius: the override now replaces a NONZERO
// netTypeFor answer on any INSTANTIATED interface.  Same cells, plus the
// UNINSTANTIATED twin as the control.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
  typedef cv_t        cv2_t;
endpackage
typedef logic [1:0] uv_t;
interface ifx;
  import pk::*;
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  typedef lv_t [1:0]  lw_t;
  wire  cv_t n01;
  wand  cv_t n02;
  wire  cr_t n03;
  wire  uv_t n04;
  wire  lv_t n05;
  wand  lv_t n06;
  wire  lr_t n07;
  wire  lw_t n08;
  wire  cv2_t n09;
  cv_t  n10;
  lv_t  n11;
  wire  logic [1:0] n12;
  wand  logic [1:0] n13;
  supply0 lv_t n14;
  uwire   lv_t n15;
  tri0    lv_t n16;
  wire  lv_t [1:0] n17;
  wire  cv_t [1:0] n18;
  wire  lv_t n19 [2];
  wand  lv_t n20 [2];
  wire  cv_t n21 [2];
endinterface
interface ifu;
  import pk::*;
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  wire  cv_t q01;
  wire  lv_t q02;
  wand  lv_t q03;
  wire  lr_t q04;
  lv_t  q05;
  wire  lv_t q06 [2];
endinterface
module w2;
  ifx u_ifx();
  logic z;
  assign z = u_ifx.n01[0];
endmodule
