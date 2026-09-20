// w3_home -- HOMES aliasHomeNeverRebound67 does not name: a generate block,
// an interface, a nested module, a second package, and a package typedef
// written over an IMPORTED name from another package.
package pa;
  typedef logic [1:0] av_t;
  typedef reg   [1:0] ar_t;
endpackage
package pb;
  import pa::*;
  typedef av_t bv_t;        // package alias over an IMPORTED package name
  typedef logic [1:0] bs_t; // package SIMPLE
  typedef bs_t bs2_t;       // package alias over a name in the SAME package
endpackage
typedef logic [1:0] us_t;
typedef us_t us2_t;         // $unit alias over a $unit name
module w3;
  import pa::*;
  import pb::*;
  typedef logic [1:0] lv_t;
  bv_t   h01;
  wire bv_t h02;
  bs2_t  h03;
  wire bs2_t h04;
  us2_t  h05;
  wire us2_t h06;
  if (1) begin : gb
    typedef logic [1:0] gv_t;
    typedef gv_t gw_t;
    typedef gv_t [1:0] gp_t;
    gv_t  h07;
    gw_t  h08;
    gp_t  h09;
    wire gv_t h10;
    wire gp_t h11;
  end
  sub u_sub();
endmodule
module sub;
  typedef logic [1:0] sv_t;
  typedef sv_t [1:0] sp_t;
  sv_t  h12;
  sp_t  h13;
  wire sv_t h14;
endmodule
