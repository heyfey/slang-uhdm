// v8 - ISOLATING THE ALIAS-DEPTH x HOME cell that v2 caught moving AWAY from
// golden.  Every combination of {local, imported} x {single alias, alias of
// alias, packed-array-of-alias} x {declarator dim, unpacked typedef element}.
package pkc;
  typedef logic [1:0] cv_t;        // single
  typedef cv_t        cv2_t;       // alias OF alias
  typedef cv_t [1:0]  cw_t;        // packed array OF an alias
  typedef cv_t        ca_t [2];    // unpacked typedef, SINGLE-alias element
  typedef cv2_t       cb_t [2];    // unpacked typedef, DOUBLE-alias element
  typedef cw_t        cc_t [2];    // unpacked typedef, packedarr-of-alias elem
endpackage
module dut (output logic [1:0] o);
  import pkc::*;
  typedef logic [1:0] lv_t;
  typedef lv_t        lv2_t;
  typedef lv_t [1:0]  lw_t;
  typedef lv_t        la_t [2];
  typedef lv2_t       lb_t [2];
  typedef lw_t        lc_t [2];

  lv_t  d01 [2];   // LOCAL single alias + declarator dim
  lv2_t d02 [2];   // LOCAL double alias + declarator dim
  lw_t  d03 [2];   // LOCAL packedarr-of-alias + declarator dim
  la_t  d04;       // LOCAL unpacked typedef, single-alias element
  lb_t  d05;       // LOCAL unpacked typedef, double-alias element
  lc_t  d06;       // LOCAL unpacked typedef, packedarr-of-alias element
  cv_t  d07 [2];   // IMPORTED single alias + declarator dim
  cv2_t d08 [2];   // IMPORTED double alias + declarator dim
  cw_t  d09 [2];   // IMPORTED packedarr-of-alias + declarator dim
  ca_t  d10;       // IMPORTED unpacked typedef, single-alias element
  cb_t  d11;       // IMPORTED unpacked typedef, double-alias element
  cc_t  d12;       // IMPORTED unpacked typedef, packedarr-of-alias element
  lv_t  d13;       // LOCAL single alias, NO dim (control)
  lv2_t d14;       // LOCAL double alias, NO dim (control)
  lw_t  d15;       // LOCAL packedarr-of-alias, NO dim (control)
  cv2_t d16;       // IMPORTED double alias, NO dim (control)

  assign o = d01[0] | d02[0] | d03[0][0] | d04[0] | d05[0] | d06[0][0] |
             d07[0] | d08[0] | d09[0][0] | d10[0] | d11[0] | d12[0][0] |
             d13 | d14 | d15[0] | d16;
endmodule
