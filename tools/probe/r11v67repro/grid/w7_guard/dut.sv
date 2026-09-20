// w7_guard -- the aliasOfAlias0 guard's new opening: a PACKED-ARRAY-OF-ALIAS
// typedef, by the home of the typedef AND the home of the alias below it.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
  typedef cv_t [1:0]  cw_t;
endpackage
typedef logic [1:0] uv_t;
typedef uv_t [1:0]  uw_t;
module w7;
  import pk::*;
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  typedef lv_t [1:0]  lw_t;    // LOCAL over LOCAL simple
  typedef cv_t [1:0]  mw_t;    // LOCAL over PACKAGE simple
  typedef uv_t [1:0]  nw_t;    // LOCAL over $unit simple
  typedef lr_t [1:0]  rw_t;    // LOCAL over LOCAL reg simple
  typedef cr_t [1:0]  sw_t;    // LOCAL over PACKAGE reg simple
  lw_t g01;
  mw_t g02;
  nw_t g03;
  rw_t g04;
  sw_t g05;
  wire lw_t g06;
  wire mw_t g07;
  wand mw_t g08;
  wire rw_t g09;
  wire sw_t g10;
  cw_t g11;
  uw_t g12;
  wire cw_t g13;
  wire uw_t g14;
  lw_t g15 [2];
  mw_t g16 [2];
  wire mw_t [1:0] g17;
endmodule
